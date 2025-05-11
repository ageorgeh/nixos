{ config, pkgs, ... }:

{
  # https://search.nixos.org/options?channel=unstable&show=services.kanata.package&from=0&size=50&sort=relevance&type=packages&query=services.kanata
  services.kanata = {
    enable = true;
    keyboards = {
      "annePro" = {
        # https://github.com/jtroo/kanata/blob/main/docs/config.adoc
        extraDefCfg = ''
          
        '';
        config = ''

          (defsrc
            esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet prtsc rctl
          )

          (defalias
            capAsEsc (tap-hold 100 100 esc lctl)
            emergency (layer-while-held emergency)
          )

          (deflayer default
            grave 1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            @capAsEsc  a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet prtsc @emergency
          )

          ;; If something fucks up and i need to reset hold right alt
          (deflayer emergency
            esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet prtsc @emergency
          )
        '';
      };
    };
  };
}
