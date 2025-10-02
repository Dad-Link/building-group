#!/usr/bin/env python3
import os, sys, datetime, xml.etree.ElementTree as ET

DOMAIN = "https://building-group.co.uk"
WEBROOT = "public"  # path to your static site root
EXCLUDE_DIRS = {"account"}  # add more if needed, e.g., {"account", "drafts"}
INCLUDE_EXT = ".html"
OUTPUT = os.path.join(WEBROOT, "sitemap.xml")

# Set to True only if your server supports extensionless routes
USE_EXTENSIONLESS = False

def rel_to_url(rel_path: str) -> str:
    # Normalize to URL path
    url_path = "/" + rel_path.replace(os.sep, "/").lstrip("/")
    # Special-case index.html
    if url_path == "/index.html":
        return "/"
    # Optionally make extensionless (only when safe)
    if USE_EXTENSIONLESS and url_path.endswith(INCLUDE_EXT):
        url_path = url_path[: -len(INCLUDE_EXT)]
    return url_path

def isoformat_mtime(path: str) -> str:
    ts = os.path.getmtime(path)
    # ISO 8601 with timezone offset +00:00 (UTC)
    dt = datetime.datetime.utcfromtimestamp(ts).replace(tzinfo=datetime.timezone.utc)
    return dt.isoformat(timespec="seconds")

def main():
    urls = []
    for root, dirs, files in os.walk(WEBROOT):
        # Exclude directories by name at any depth
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for fname in files:
            if fname == "sitemap.xml":
                continue
            if not fname.endswith(INCLUDE_EXT):
                continue
            full_path = os.path.join(root, fname)
            rel_path = os.path.relpath(full_path, WEBROOT)
            url_path = rel_to_url(rel_path)
            lastmod = isoformat_mtime(full_path)
            urls.append((DOMAIN + url_path, lastmod))

    # Sort for stable output
    urls.sort(key=lambda x: x[0])

    urlset = ET.Element("urlset", {
        "xmlns": "http://www.sitemaps.org/schemas/sitemap/0.9"
    })

    for loc, lastmod in urls:
        url_el = ET.SubElement(urlset, "url")
        ET.SubElement(url_el, "loc").text = loc
        ET.SubElement(url_el, "lastmod").text = lastmod

    tree = ET.ElementTree(urlset)
    ET.indent(tree, space="  ", level=0)  # Python 3.9+
    with open(OUTPUT, "wb") as f:
        f.write(b'<?xml version="1.0" encoding="UTF-8"?>\n')
        tree.write(f, encoding="utf-8", xml_declaration=False)

    print(f"Wrote {OUTPUT} with {len(urls)} URLs.")

if __name__ == "__main__":
    sys.exit(main())
