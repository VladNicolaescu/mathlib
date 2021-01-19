#!/usr/bin/env python3
from pathlib import Path
from tempfile import NamedTemporaryFile
import subprocess
import unittest


SCRIPTS_DIR = Path(__file__).parent.resolve()
ROOT_DIR = SCRIPTS_DIR.parent


class TestLinterIntegration(unittest.TestCase):
    def test_path_combinations(self):
        combinations = [
            (
                ("relative", "./lint-style.py"),
                ("relative", "../src/data/bool.lean"),
            ),
            (
                ("relative", "./lint-style.py"),
                ("absolute", (ROOT_DIR / "src/data/bool.lean").resolve()),
            ),
            (
                ("absolute", (SCRIPTS_DIR / "lint-style.py").resolve()),
                ("relative", "../src/data/bool.lean"),
            ),
            (
                ("absolute", (SCRIPTS_DIR / "lint-style.py").resolve()),
                ("absolute", (ROOT_DIR / "src/data/bool.lean").resolve()),
            ),
        ]

        for (linter_kind, linter_path), (file_kind, file_path) in combinations:
            with self.subTest(linter_kind=linter_kind, file_kind=file_kind):
                subprocess.run(
                    [linter_path, file_path],
                    check=True,
                    cwd=SCRIPTS_DIR,
                )

    def test_it_fails_for_missing_copyright_headers(self):
        with NamedTemporaryFile(suffix=".lean") as file:
            file.write(b"example : 37 = 37\n")
            file.flush()
            output = subprocess.run(
                [SCRIPTS_DIR / "lint-style.py", file.name],
                capture_output=True,
            )
        self.assertIn(b"ERR_COP :", output.stdout)


if __name__ == "__main__":
    unittest.main()
