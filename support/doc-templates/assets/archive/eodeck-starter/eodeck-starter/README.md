# EO Deck Starter (Layouts-Only)
Generate EO Framework decks from JSON/YAML using a .potx master — no demo slides required.

## Quickstart
```
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt

python build.py --template template/EOFramework_BrandMaster_OpenSans.potx                 --content content/sample_deck.yaml                 --out out/EO_Deck_From_YAML.pptx
```
