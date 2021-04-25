# Document Viewer
This is a web-based document viewer for the following document formats:
1. ePub 2 and 3.

## Setup
To run this project, you need to copy a BaseX installation into the project
directory and ignore/skip any files that will be overrided (or run the
`git checkout -f` command after copying the files over).

You can then start the HTTP server by running the `bin/basexhttp` command.

## Usage
These examples use the default BaseX path of `http://localhost:8984`. Replace
that with the server name and port you are running on.

To view the contents of a directory, use:

    http://localhost:8984/?path=[path-to-directory]

Any directories and viewable documents will be displayed as clickable links.
Other files will be displayed as text.

To view an ePub file, use:

    http://localhost:8984/?path=[path-to-epub.epub]

When viewing a directory or document, there will be a "Back" button on the top
right that navigates up to the parent directory.

## License
Copyright (C) 2021 Reece H. Dunn

The document viewer project is licensed under the [Apache 2.0](LICENSE) license.
