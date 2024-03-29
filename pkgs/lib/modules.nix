# NixOS module handling.

let lib = import ./default.nix; in

with { inherit (builtins) head tail; };
with import ./trivial.nix;
with import ./lists.nix;
with import ./misc.nix;
with import ./attrsets.nix;
with import ./options.nix;
with import ./properties.nix;

rec {

  # Unfortunately this can also be a string.
  isPath = x: !(
     builtins.isFunction x
  || builtins.isAttrs x
  || builtins.isInt x
  || builtins.isBool x
  || builtins.isList x
  );

  importIfPath = path:
    if isPath path then
      import path
    else
      path;

  applyIfFunction = f: arg:
    if builtins.isFunction f then
      f arg
    else
      f;

  isModule = m:
       (m ? config && isAttrs m.config && ! isOption m.config)
    || (m ? options && isAttrs m.options && ! isOption m.options);

  # Convert module to a set which has imports / options and config
  # attributes.
  unifyModuleSyntax = m:
    let
      getImports = m:
        if m ? config || m ? options then
          attrByPath ["imports"] [] m
        else
          toList (rmProperties (attrByPath ["require"] [] (delayProperties m)));

      getImportedPaths = m: filter isPath (getImports m);
      getImportedSets = m: filter (x: !isPath x) (getImports m);

      getConfig = m:
        removeAttrs (delayProperties m) ["require" "key"];
    in
      if isModule m then
        { key = "<unknown location>"; } // m
      else
        {
          key = "<unknown location>";
          imports = getImportedPaths m;
          config = getConfig m;
        } // (
          if getImportedSets m != [] then
            assert tail (getImportedSets m) == [];
            { options = head (getImportedSets m); }
          else
            {}
        );


  unifyOptionModule = {key ? "<unknown location>"}: m: (args:
    let module = lib.applyIfFunction m args; in
    if lib.isModule module then
      { inherit key; } // module
    else
      { inherit key; options = module; }
  );


  moduleClosure = initModules: args:
    let
      moduleImport = origin: index: m:
        let m' = applyIfFunction (importIfPath m) args;
        in (unifyModuleSyntax m') // {
          # used by generic closure to avoid duplicated imports.
          key =
            if isPath m then m
            else if m' ? key then m'.key
            else newModuleName origin index;
        };

      getImports = m: attrByPath ["imports"] [] m;

      newModuleName = origin: index:
        "${origin.key}:<import-${toString index}>";

      topLevel = {
        key = "<top-level>";
      };

    in
      (lazyGenericClosure {
        startSet = imap (moduleImport topLevel) initModules;
        operator = m: imap (moduleImport m) (getImports m);
      });

  selectDeclsAndDefs = modules:
    lib.concatMap (m:
      if m ? config || m ? options then
         [ (attrByPath ["options"] {} m) ]
      ++ [ (attrByPath ["config"] {} m) ]
      else
        [ m ]
    ) modules;


  moduleApply = funs: module:
    lib.mapAttrs (name: value:
      if builtins.hasAttr name funs then
        let fun = lib.getAttr name funs; in
        fun value
      else
        value
    ) module;


  delayModule = module:
    moduleApply { config = delayProperties; } module;

  evalDefinitions = opt: values:
    if opt ? type && opt.type.delayOnGlobalEval then
      map (delayPropertiesWithIter opt.type.iter opt.name)
        (evalLocalProperties values)
    else
      evalProperties values;


  selectModule = name: m:
    { inherit (m) key;
    } // (
      if m ? options && builtins.hasAttr name m.options then
        { options = lib.getAttr name m.options; }
      else {}
    ) // (
      if m ? config && builtins.hasAttr name m.config then
        { config = lib.getAttr name m.config; }
      else {}
    );

  filterModules = name: modules:
    filter (m: m ? config || m ? options) (
      map (selectModule name) modules
    );

  modulesNames = modules:
    lib.concatMap (m: []
    ++ optionals (m ? options) (lib.attrNames m.options)
    ++ optionals (m ? config) (lib.attrNames m.config)
    ) modules;

  moduleZip = funs: modules:
    lib.mapAttrs (name: fun:
      fun (catAttrs name modules)
    ) funs;

  moduleMerge = path: modules:
    let modules_ = modules; in
    let
      addName = name:
        if path == "" then name else path + "." + name;

      modules = map delayModule modules_;

      modulesOf = name: filterModules name modules;
      declarationsOf = name: filter (m: m ? options) (modulesOf name);
      definitionsOf  = name: filter (m: m ? config ) (modulesOf name);

      recurseInto = name:
        moduleMerge (addName name) (modulesOf name);

      recurseForOption = name: modules:
        moduleMerge name (
          map unifyModuleSyntax modules
        );

      errorSource = modules:
        "The error may come from the following files:\n" + (
          lib.concatStringsSep "\n" (
            map (m:
              if m ? key then toString m.key else "<unknown location>"
            ) modules
          )
        );

      eol = "\n";

      allNames = modulesNames modules;

      getResults = m:
        let fetchResult = s: mapAttrs (n: v: v.result) s; in {
          options = fetchResult m.options;
          config = fetchResult m.config;
        };

      endRecursion =  { options = {}; config = {}; };

    in if modules == [] then endRecursion else
      getResults (fix (crossResults: moduleZip {
        options = lib.zipWithNames allNames (name: values: rec {
          config = lib.getAttr name crossResults.config;

          declarations = declarationsOf name;
          declarationSources =
            map (m: {
              source = m.key;
            }) declarations;


          hasOptions = values != [];
          isOption = any lib.isOption values;

          decls = # add location to sub-module options.
            map (m:
              mapSubOptions
                (unifyOptionModule {inherit (m) key;})
                m.options
            ) declarations;

          decl =
            lib.addErrorContext "${eol
              }while enhancing option `${addName name}':${eol
              }${errorSource declarations}${eol
            }" (
              addOptionMakeUp
                { name = addName name; recurseInto = recurseForOption; }
                (mergeOptionDecls decls)
            );

          value = decl // (with config; {
            inherit (config) isNotDefined;
            isDefined = ! isNotDefined;
            declarations = declarationSources;
            definitions = definitionSources;
            config = strictResult;
          });

          recurse = (recurseInto name).options;

          result =
            if isOption then value
            else if !hasOptions then {}
            else if all isAttrs values then recurse
            else
              throw "${eol
                }Unexpected type where option declarations are expected.${eol
                }${errorSource declarations}${eol
              }";

        });

        config = lib.zipWithNames allNames (name: values_: rec {
          option = lib.getAttr name crossResults.options;

          definitions = definitionsOf name;
          definitionSources =
            map (m: {
              source = m.key;
              value = m.config;
            }) definitions;

          values = values_ ++
            optionals (option.isOption && option.decl ? extraConfigs)
              option.decl.extraConfigs;

          defs = evalDefinitions option.decl values;

          isNotDefined = defs == [];

          value =
            lib.addErrorContext "${eol
              }while evaluating the option `${addName name}':${eol
              }${errorSource (modulesOf name)}${eol
            }" (
              let opt = option.decl; in
              opt.apply (
                if isNotDefined then
                  if opt ? default then opt.default
                  else throw "Not defined."
                else opt.merge defs
              )
            );

          strictResult = builtins.tryEval (builtins.toXML value);

          recurse = (recurseInto name).config;

          configIsAnOption = v: isOption (rmProperties v);
          errConfigIsAnOption =
            let badModules = filter (m: configIsAnOption m.config) definitions; in
            "${eol
              }Option ${addName name} is defined in the configuration section.${eol
              }${errorSource badModules}${eol
            }";

          errDefinedWithoutDeclaration =
            let badModules = definitions; in
            "${eol
              }Option '${addName name}' defined without option declaration.${eol
              }${errorSource badModules}${eol
            }";

          result =
            if option.isOption then value
            else if !option.hasOptions then throw errDefinedWithoutDeclaration
            else if any configIsAnOption values then throw errConfigIsAnOption
            else if all isAttrs values then recurse
            # plain value during the traversal
            else throw errDefinedWithoutDeclaration;

        });
      } modules));


  fixMergeModules = initModules: {...}@args:
    lib.fix (result:
      # This trick avoid an infinite loop because names of attribute are
      # know and it is not require to evaluate the result of moduleMerge to
      # know which attribute are present as argument.
      let module = { inherit (result) options config; }; in

      moduleMerge "" (
        moduleClosure initModules (module // args)
      )
    );

  # Visit all definitions to raise errors related to undeclared options.
  checkModule = path: {config, options, ...}@m:
    let
      eol = "\n";
      addName = name:
        if path == "" then name else path + "." + name;
    in
    if lib.isOption options then
      if options ? options then
        options.type.fold
          (cfg: res: res && checkModule (options.type.docPath path) cfg._args)
          true config
      else
        true
    else if isAttrs options && lib.attrNames m.options != [] then
      all (name:
        lib.addErrorContext "${eol
          }while checking the attribute `${addName name}':${eol
        }" (checkModule (addName name) (selectModule name m))
      ) (lib.attrNames m.config)
    else
      builtins.trace "try to evaluate config ${lib.showVal config}."
      false;

}
