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
