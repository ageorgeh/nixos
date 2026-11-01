"""Check the small workstation shortcut contract without sending desktop input."""
import json
from pathlib import Path
import runpy
from tempfile import TemporaryDirectory
from types import SimpleNamespace
import unittest
from unittest.mock import patch

editor = runpy.run_path(str(Path(__file__).with_name("resolve-editor.py")))


class AdapterTests(unittest.TestCase):
    def invoke(self, action, title="DaVinci Resolve Studio - Test"):
        dispatches = []
        def boundary(argv, **kwargs):
            if "instances" in argv:
                output = json.dumps([{"instance":"test-session"}])
            elif "clients" in argv:
                output = json.dumps([{"class":"resolve","title":title,"address":"0x123"}])
            else:
                self.assertIn("dispatch", argv)
                dispatches.append(argv[-1])
                output = "ok\n"
            return SimpleNamespace(stdout=output)
        with TemporaryDirectory() as home, patch.object(editor["Path"],"home",return_value=Path(home)), \
             patch.object(editor["subprocess"],"run",side_effect=boundary), patch.object(editor["time"],"sleep"):
            result = editor["run"](action,"Test")
        return result, dispatches

    def test_ready_advertises_supported_actions_without_input(self):
        result, keys = self.invoke("ready")
        self.assertEqual(result["actions"],["prepare","split"])
        self.assertEqual(keys,[])

    def test_split_targets_only_the_resolve_window_without_focus_or_delete_commands(self):
        result, keys = self.invoke("split")
        self.assertEqual(result["window"],"0x123")
        self.assertEqual(keys,['hl.dsp.send_shortcut({mods="CTRL",key="b",window="address:0x123"})'])

    def test_prepare_targets_timeline_and_deselects(self):
        _, keys = self.invoke("prepare")
        self.assertEqual(keys,[
            'hl.dsp.send_shortcut({mods="CTRL",key="4",window="address:0x123"})',
            'hl.dsp.send_shortcut({mods="CTRL SHIFT",key="a",window="address:0x123"})'])

    def test_wrong_project_is_rejected(self):
        with self.assertRaisesRegex(AssertionError,"project changed"):
            self.invoke("split",title="DaVinci Resolve Studio - Other")


if __name__ == "__main__":
    unittest.main()
