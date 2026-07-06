{
  pkgs ? import <nixpkgs> { config.allowUnfree = true; },
}:

pkgs.mkShell {
  packages = with pkgs; [
    git
    uv
    python313
    stdenv.cc
    zlib
    libGL
    # xorg.libX11
    # xorg.libXext
    # libxcb
    # xorg.libXrender
    # xorg.libXi
    # xorg.libXrandr
    # ffmpeg
    # imagemagick
    # potrace
    # nodePackages.svgo
  ];
  buildInputs = with pkgs; [
    pythonManylinuxPackages.manylinux2014Package
    cmake
    ninja
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${
      pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc.lib
        pkgs.pythonManylinuxPackages.manylinux2014Package
        pkgs.libxcb
        pkgs.libX11
        pkgs.libGL
        pkgs.glib
      ]
    }:/run/opengl-driver/lib:/run/opengl-driver-32/lib:$LD_LIBRARY_PATH"
  '';
}

# Install

# mkdir -p ~/ai/comfyui-runtime
# cd ~/ai/comfyui-runtime
# nix-shell ~/nixos/shells/comfyui.nix

# git clone https://github.com/Comfy-Org/ComfyUI.git
# uv venv .venv --python "$(which python)"

# cd ComfyUI
# uv pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130
# uv pip install -r requirements.txt

# Start

# cd ~/ai/comfyui-runtime/ComfyUI
# nix-shell ~/nixos-config/shells/comfyui.nix
# ../.venv/bin/python main.py --listen 127.0.0.1 --port 8188
