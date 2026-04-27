{ inputs, config, ... }: {
    imports = [inputs.silentSDDM.nixosModules.default];
    programs.silentSDDM = {
        enable = true;
        theme = config.myConfig.sddmTheme;
        # settings = { ... }; see example in module
    };
}