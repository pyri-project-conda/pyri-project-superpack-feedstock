set -e

if ! [ -x "$(command -v npm)" ]; then
  echo NodeJS npm command is not found. Install NodeJS before continuing
  exit 1
fi

export package_names="pyri-common
pyri-variable-storage
pyri-device-manager 
pyri-devices-states
pyri-sandbox
pyri-program-master
pyri-webui-server
pyri-core
pyri-robotics
pyri-vision
"

for x in $package_names
do
    $PYTHON -m pip install --no-deps --ignore-installed ./$x -vv
done

pyri-sandbox-service --install-blockly-compiler --blockly-compiler-dir=$PREFIX/pyri-project/pyri-sandbox/blockly_compiler

cd scripts
$PYTHON install_webui_browser_wheels.py --static-data-dir=$PREFIX/pyri-project/pyri-webui-server
$PYTHON install_webui_browser_deps.py --static-data-dir=$PREFIX/pyri-project/pyri-webui-server

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
