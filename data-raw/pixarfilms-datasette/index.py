import asyncio
from datasette.app import Datasette
import json
import pathlib
import os

static_mounts = [
    (static, str((pathlib.Path(".") / static).resolve()))
    for static in []
]

metadata = dict()
try:
    metadata = json.load(open("metadata.json"))
except Exception:
    pass

secret = os.environ.get("DATASETTE_SECRET")

true, false = True, False

ds = Datasette(
    [],
    ["pixarfilms.db"],
    static_mounts=static_mounts,
    metadata=metadata,
    secret=secret,
    cors=True,
    settings={}
)
asyncio.run(ds.invoke_startup())
app = ds.app()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("index:app", host="127.0.0.1", port=8001, reload=True)
