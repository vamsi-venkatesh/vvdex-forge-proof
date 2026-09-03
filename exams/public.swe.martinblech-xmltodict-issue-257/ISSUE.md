# Streaming mode silently drops an element's text

Upstream report: https://github.com/martinblech/xmltodict/issues/257

`parse(..., item_depth=N, item_callback=...)` hands each element at depth `N`
to the callback instead of building the whole document. The callback is
supposed to receive what that element would have been worth in the full
document — but the streaming branch in `_DictSAXHandler.endElement` builds the
item itself, and it does less than the non-streaming branch does.

```python
>>> xmltodict.parse('<items><item id="1">hello</item></items>',
...                 item_depth=2, item_callback=show)
{'@id': '1'}                       # 'hello' is gone
>>> xmltodict.parse('<items><item id="1">hello</item></items>')
{'items': {'item': {'@id': '1', '#text': 'hello'}}}
```

The character data is only used when the item has no attributes and no
children; as soon as either is present it is discarded. And on the text-only
path the streamed value skips the handling the non-streaming path applies to
the same text — `strip_whitespace`, `force_cdata`, `cdata_key` and the
`postprocessor`.

Reported as "what happens to free text in the streaming API": text nodes appear
for some elements and are missing for others, with nothing in the API to
explain the difference.
