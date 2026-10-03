install-linux-with-npie:
  runs-on: 'ubuntu-latest'
  needs: build
  container:
    image: perl:5.34
  steps:
    - uses: actions/download-artifact@v8.0.1
      with:
        name: dist-for-install
    - name: Install on Linux with Number::Phone::IE already installed
      run: |
        cpanm Number::Phone::IE &&
        cpanm *.tar.gz
install-windows:
  runs-on: windows-latest
  needs: build
  strategy:
    fail-fast: false
    matrix:
      perl-version:
      - latest
  steps:
    - name: Set up perl
      uses: shogo82148/actions-setup-perl@v1
      with:
        distribution: strawberry
        perl-version: ${{ matrix.perl-version }}
    - uses: actions/download-artifact@v8.0.1
      with:
        name: dist-for-install
    - name: Install on Windows
      shell: pwsh
      run: |
        cpanm (Get-ChildItem -Filter *.tar.gz).FullName
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
