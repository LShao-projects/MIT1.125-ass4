"""Small stdlib HTML text extractor for original written evidence pages."""

from html.parser import HTMLParser
import re


class Paragraphs(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack = []
        self.next_article = 0
        self.current = None
        self.parts = []
        self.records = []

    def handle_starttag(self, tag, attrs):
        if tag == "article":
            self.next_article += 1
            article = self.next_article
        else:
            article = self.stack[-1][1] if self.stack else None
        main = tag == "main" or (self.stack[-1][2] if self.stack else False)
        self.stack.append((tag, article, main))
        if tag in {"p", "h1", "h2", "h3", "h4", "blockquote", "li"} and self.current is None:
            self.current = (tag, article, main)
            self.parts = []

    def handle_endtag(self, tag):
        if self.current and tag == self.current[0]:
            value = " ".join("".join(self.parts).split())
            if len(value) >= 18:
                self.records.append((*self.current, value))
            self.current = None
            self.parts = []
        for i in range(len(self.stack) - 1, -1, -1):
            if self.stack[i][0] == tag:
                del self.stack[i:]
                break

    def handle_data(self, data):
        if self.current and not any(tag in {"script", "style", "noscript", "svg", "nav", "footer", "form"} for tag, _, _ in self.stack):
            self.parts.append(data)


def extract_paragraphs(html, target_section=None):
    parser = Paragraphs()
    parser.feed(html)
    groups = {}
    for _, article, main, value in parser.records:
        if article is not None:
            groups.setdefault(article, []).append(value)
    if target_section:
        tokens = [x.lower() for x in re.findall(r"[A-Za-z0-9]+", target_section) if len(x) > 3]
        matches = [(key, values) for key, values in groups.items()
                   if all(token in " ".join(values).lower() for token in tokens)]
        if matches:
            return max(matches, key=lambda pair: len(" ".join(pair[1])))[1]
    if groups:
        best = max(groups.values(), key=lambda values: len(" ".join(values)))
        if len(" ".join(best)) >= 450:
            return best
    main_values = [value for _, _, main, value in parser.records if main]
    if len(" ".join(main_values)) >= 450:
        return main_values
    return [value for _, _, _, value in parser.records]
