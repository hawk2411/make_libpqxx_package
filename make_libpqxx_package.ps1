function Start-VsDev {
    Push-Location "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools"
    ./Launch-VsDevShell.ps1 -Arch amd64 -HostArch amd64
    Pop-Location
    Write-Host "`nVisual Studio 2022 Command Prompt variables set." -ForegroundColor Yellow
}

if ($env:VisualStudioVersion) {
    Write-Host "Found Visual C++ compiler environment."
} else {
    Write-Host "Cannot found Visual C++ compiler environment."
}

Push-Location

$libpqxx_repository_name = "libpqxx"

# Check if path exists
$libpqxx_repository_path = Join-Path -Path (Get-Location) -ChildPath $libpqxx_repository_name

if (!(Test-Path -Path $libpqxx_repository_path)) {
    
    # if the path not exists clone it
    Write-Host "Cannot find local repository. Try to clone it."
    git clone git@github.com:jtv/libpqxx.git
    if ($LASTEXITCODE -eq 0) {
        Write-Host "clone succeded!" -ForegroundColor Gray
    } else {
        Write-Host "Clone of repository failed." -ForegroundColor Red
        return 1
    }    
}

Set-Location -Path $libpqxx_repository_path
git pull

git checkout 7.10.0

Pop-Location

$package_path = Join-Path -Path(Get-Location) -ChildPath "OSS.libpq"
$package_path_include = $package_path+"/include"
$package_path_doc = $package_path+"/doc"
$package_path_lib_release = $package_path+"/lib/release"
$package_path_lib_debug = $package_path+"/lib/debug"

$release_path = Join-Path -Path(Get-Location) -ChildPath "cmake-build-release"
$debug_path = Join-Path -Path(Get-Location) -ChildPath "cmake-build-debug"

$package_path_lib_
if (Test-Path -Path $package_path) {
    Remove-Item -Force -Recurse -Path $package_path
}
mkdir $package_path

if (Test-Path -Path $release_path ) {
    Remove-Item -Force -Recurse -Path $release_path
}
mkdir $release_path

if (Test-Path -Path $debug_path) {
    Remove-Item -Force -Recurse -Path $debug_path
}

mkdir $debug_path

Push-Location
#------------------------------------------------------------------------
Set-Location -Path $release_path

cmake -G "Ninja" -DCMAKE_CXX_STANDARD=20 -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_INCLUDEDIR="$package_path_include" -DCMAKE_INSTALL_LIBDIR="$package_path_lib_release" -DCMAKE_INSTALL_DOCDIR="$package_path_doc" $libpqxx_repository_path

cmake --build .

cmake --install .

Pop-Location

Push-Location

Set-Location -Path $debug_path

cmake -G "Ninja" -DCMAKE_CXX_STANDARD=20 -DCMAKE_BUILD_TYPE:STRING=Debug -DCMAKE_INSTALL_INCLUDEDIR="$package_path_include" -DCMAKE_INSTALL_LIBDIR="$package_path_lib_debug" -DCMAKE_INSTALL_DOCDIR="$package_path_doc" $libpqxx_repository_path

cmake --build .

cmake --install .

Pop-Location

