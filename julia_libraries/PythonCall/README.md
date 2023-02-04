- `PythonCall` allows users to call python code in Julia.

- `JuliaCall` allows users to call julia call in Python.

One must ensure that both Julia and Python use the same underlying CPU 
arquitecture. If you are using a mac with arm (M1, M1 pro etc...) you have 
to ensure that both Python and Julia use ARM or Roesseta.


### Which platform is python using?

You can call the following to get the information

```
import platform
platform.uname()[4]
```

This should print `'arm64'` or `'X86_64'`.

### How can I set up a python environment to match the Julia backend?

The following code can be used to set up `X86` architecture

```
CONDA_SUBDIR=osx-64 conda create -n rosetta python=3.9
conda activate rosetta
python -c "import platform;print(platform.machine())"
conda env config vars set CONDA_SUBDIR=osx-64
```
This should print `x86_64`

The following code can be used to set up `arm64` architecture

```
CONDA_SUBDIR=osx-arm64  conda create -n env_arm64 python=3.9
conda activate env_arm64
python -c "import platform;print(platform.machine())"
conda env config vars set CONDA_SUBDIR=arm64
conda deactivate
conda activate env_arm64
```
This should print `arm64`

