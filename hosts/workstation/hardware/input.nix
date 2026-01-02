{ ... }:

{
  # https://search.nixos.org/options?channel=unstable&show=services.kanata.package&from=0&size=50&sort=relevance&type=packages&query=services.kanata
  services.kanata = {
    enable = true;
    keyboards = {
      "magicKeyboard" = {
        devices = [
          "/dev/input/by-id/usb-Apple_Inc._Magic_Keyboard_with_Touch_ID_and_Numeric_Keypad_F0T3076RRVC0XXQAM-if01-event-kbd"
        ];
        config = ''

          (defsrc
            grave 1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lalt lmet           spc            rmet ralt rctl
          )

          (defalias
            capAsEsc (tap-hold 150 150 esc lctl)
            emergency (layer-while-held emergency)
          )

          (deflayer default
            grave 1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            @capAsEsc  a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet @emergency
          )

          ;; If something fucks up and i need to reset hold right alt
          (deflayer emergency
            grave 1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet @emergency
          )

        '';
      };
      "annePro" = {
        # https://github.com/jtroo/kanata/blob/main/docs/config.adoc
        devices = [
          "/dev/input/by-id/usb-OBINS_OBINS_AnnePro2_00000000000000000000000000000000-event-kbd"
        ];
        extraDefCfg = '''';
        config = ''

          (defsrc
            esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet prtsc rctl
          )

          (defalias
            capAsEsc (tap-hold 150 150 esc lctl)
            emergency (layer-while-held emergency)
          )

          (deflayer default
            grave 1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            @capAsEsc  a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet prtsc @emergency
          )

          ;; If something breaks and i need to reset hold right alt
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
