#!/usr/bin/env python3
"""Validate the generated Hugo site using only the Python standard library."""

from __future__ import annotations

import argparse
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlparse
import xml.etree.ElementTree as ET


class PageParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.html_lang = ""
        self.title_parts: list[str] = []
        self.in_title = False
        self.meta: dict[str, str] = {}
        self.links: list[tuple[str, str, str]] = []
        self.images: list[tuple[str, str | None]] = []
        self.ids: list[str] = []
        self.h1_count = 0

    def handle_starttag(self, tag: str, attrs_list: list[tuple[str, str | None]]) -> None:
        attrs = dict(attrs_list)
        tag = tag.lower()

        if tag == "html":
            self.html_lang = attrs.get("lang") or ""
        elif tag == "title":
            self.in_title = True
        elif tag == "meta":
            key = attrs.get("name") or attrs.get("property")
            if key:
                self.meta[key.lower()] = attrs.get("content") or ""
        elif tag == "link":
            rel = attrs.get("rel") or ""
            href = attrs.get("href") or ""
            if "canonical" in rel.lower():
                self.meta["canonical"] = href
            if href:
                self.links.append((href, attrs.get("target") or "", attrs.get("rel") or ""))
        elif tag == "a":
            href = attrs.get("href") or ""
            if href:
                self.links.append((href, attrs.get("target") or "", attrs.get("rel") or ""))
        elif tag in {"script", "img", "source"}:
            src = attrs.get("src") or ""
            if src:
                self.links.append((src, "", ""))
            if tag == "img":
                self.images.append((src, attrs.get("alt")))
        elif tag == "h1":
            self.h1_count += 1

        element_id = attrs.get("id")
        if element_id:
            self.ids.append(element_id)

    def handle_endtag(self, tag: str) -> None:
        if tag.lower() == "title":
            self.in_title = False

    def handle_data(self, data: str) -> None:
        if self.in_title:
            self.title_parts.append(data)

    @property
    def title(self) -> str:
        return "".join(self.title_parts).strip()


def file_for_url(public_dir: Path, current_file: Path, raw_url: str) -> tuple[Path | None, str]:
    parsed = urlparse(raw_url)
    fragment = unquote(parsed.fragment)

    if parsed.scheme in {"http", "https", "mailto", "tel", "data", "javascript"} or parsed.netloc:
        return None, fragment

    path = unquote(parsed.path)
    if not path:
        return current_file, fragment

    if path.startswith("/"):
        candidate = public_dir / path.lstrip("/")
    else:
        candidate = current_file.parent / path

    if path.endswith("/"):
        candidate = candidate / "index.html"
    elif not candidate.suffix:
        directory_index = candidate / "index.html"
        if directory_index.exists():
            candidate = directory_index

    return candidate.resolve(), fragment


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("public_dir", nargs="?", default="public")
    args = parser.parse_args()

    public_dir = Path(args.public_dir).resolve()
    errors: list[str] = []

    required = [
        "index.html",
        "en/index.html",
        "404.html",
        "robots.txt",
        "sitemap.xml",
        "site.webmanifest",
        "files/CV_Luz_Graciela_Torales_ES.pdf",
        "files/Luz_Graciela_Torales_Resume_EN.pdf",
        "images/og/default.png",
    ]

    for item in required:
        if not (public_dir / item).is_file():
            errors.append(f"Missing required file: {item}")

    html_files = sorted(public_dir.rglob("*.html"))
    if not html_files:
        errors.append("No HTML files were generated")

    parsed_pages: dict[Path, PageParser] = {}

    for html_file in html_files:
        text = html_file.read_text(encoding="utf-8")
        rel = html_file.relative_to(public_dir)

        if "{{" in text or "}}" in text:
            errors.append(f"Unresolved template expression in {rel}")
        if "localhost:" in text or "127.0.0.1:" in text:
            errors.append(f"Development URL found in {rel}")

        page = PageParser()
        page.feed(text)
        parsed_pages[html_file.resolve()] = page

        if not page.html_lang:
            errors.append(f"Missing html[lang] in {rel}")
        if not page.title:
            errors.append(f"Missing title in {rel}")
        if not page.meta.get("description"):
            errors.append(f"Missing meta description in {rel}")
        if not page.meta.get("viewport"):
            errors.append(f"Missing viewport meta in {rel}")
        if not page.meta.get("canonical"):
            errors.append(f"Missing canonical URL in {rel}")
        if not page.meta.get("og:image"):
            errors.append(f"Missing Open Graph image in {rel}")
        if page.h1_count != 1:
            errors.append(f"Expected one h1 in {rel}; found {page.h1_count}")

        duplicate_ids = [item for item, count in Counter(page.ids).items() if count > 1]
        if duplicate_ids:
            errors.append(f"Duplicate IDs in {rel}: {', '.join(duplicate_ids)}")

        for src, alt in page.images:
            if alt is None:
                errors.append(f"Image without alt attribute in {rel}: {src}")

        for raw_url, target, link_rel in page.links:
            if target == "_blank":
                rel_tokens = set(link_rel.lower().split())
                if not {"noopener", "noreferrer"}.issubset(rel_tokens):
                    errors.append(f"External new-tab link lacks noopener/noreferrer in {rel}: {raw_url}")

    # Check local links and fragments after all pages have been parsed.
    for html_file, page in parsed_pages.items():
        rel = html_file.relative_to(public_dir)
        for raw_url, _, _ in page.links:
            target_file, fragment = file_for_url(public_dir, html_file, raw_url)
            if target_file is None:
                continue
            try:
                target_file.relative_to(public_dir)
            except ValueError:
                errors.append(f"Local link escapes public directory in {rel}: {raw_url}")
                continue

            if not target_file.exists():
                errors.append(f"Broken local link in {rel}: {raw_url}")
                continue

            if fragment and target_file.suffix.lower() == ".html":
                target_page = parsed_pages.get(target_file.resolve())
                if target_page and fragment not in target_page.ids:
                    errors.append(f"Missing fragment target in {rel}: {raw_url}")

    # Parse XML outputs.
    for xml_name in ("sitemap.xml",):
        xml_file = public_dir / xml_name
        if xml_file.exists():
            try:
                ET.parse(xml_file)
            except ET.ParseError as error:
                errors.append(f"Invalid {xml_name}: {error}")

    robots = public_dir / "robots.txt"
    if robots.exists() and "Sitemap:" not in robots.read_text(encoding="utf-8"):
        errors.append("robots.txt does not reference sitemap.xml")

    if errors:
        print("Site validation failed:")
        for error in errors:
            print(f" - {error}")
        return 1

    print(f"Validated {len(html_files)} HTML pages with no blocking errors.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
