{
  inputs,
  ...
}: {
    imports = [inputs.silentSDDM.nixosModules.default];
    programs.silentSDDM = {
        enable = true;
        theme = "rei";
        # settings = { ... }; see example in module
    };
}