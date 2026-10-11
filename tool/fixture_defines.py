"""Print compile-time integration inputs; no test assets in normal builds."""
import base64
import json
from pathlib import Path
root = Path(__file__).resolve().parents[1] / 'test' / 'fixtures'
print(json.dumps({
    'receipt': base64.b64encode((root / 'receipt.png').read_bytes()).decode(),
    'statement': base64.b64encode((root / 'statement.pdf').read_bytes()).decode(),
    'backup': base64.b64encode((root / 'legacy_v1.zip').read_bytes()).decode(),
    'expected': base64.b64encode((root / 'statement_expected.json').read_bytes()).decode(),
}))
