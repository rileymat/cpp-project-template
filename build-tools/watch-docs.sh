while inotifywait -q -r -e close_write ./src; do doxygen docs/doxygen.config; done
