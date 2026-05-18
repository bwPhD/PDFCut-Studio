# Third-Party Notices

This file summarizes key third-party components used by PDFCut Studio. It is a practical notice file, not a substitute for the full license texts shipped with the project and runtime.

## Briss 2.0

- Project: https://github.com/mbaeuerle/Briss-2.0
- License: GNU General Public License v3.0
- Role: upstream PDF cropper source base.

## iText

- Dependency: `com.itextpdf:itextpdf:5.5.13.4`
- License: AGPL/GPL family license as published by iText for this artifact.
- Role: PDF manipulation.

Because this project is distributed as GPL-3.0 compatible open source, keep the complete corresponding source available when distributing binaries.

## Apache PDFBox

- Dependencies: `org.apache.pdfbox:pdfbox:3.0.5`, `org.apache.pdfbox:pdfbox-tools:3.0.5`
- License: Apache License 2.0
- Role: PDF processing and tests.

## Bouncy Castle

- Dependencies: `bcprov-jdk18on:1.79`, `bcpkix-jdk18on:1.79`
- License: Bouncy Castle license
- Role: cryptography support used by PDF dependencies.

## SLF4J

- Runtime component visible in the bundled module set.
- License: MIT-style SLF4J license
- Role: logging API.

## Java Runtime

The portable package includes a Java runtime under `PDFCut-Studio/runtime`. Its own legal files are included under `PDFCut-Studio/runtime/legal`.

## PyMuPDF / MuPDF

The secure crop strategy calls the locally installed Python `fitz` / PyMuPDF module when available. PyMuPDF is not bundled in this portable package. If you decide to bundle PyMuPDF in a future release, review and include its license obligations separately before publishing.
