import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';
import { test } from 'node:test';

// Exercise the actual decoder without constructing a window or observers.
const source = await readFile(new URL('../js/silk-ui-dom.js', import.meta.url), 'utf8');
const { Page, Reader } = await import('data:text/javascript;base64,' +
  Buffer.from(source + '\nexport { Page, Reader };').toString('base64'));

function encoded(name, value) {
  const chunks = [Buffer.from([22])];
  function text(value) {
    const bytes = Buffer.from(value), size = Buffer.alloc(4);
    size.writeUInt32LE(bytes.length);
    chunks.push(size, bytes);
  }
  text(name);
  chunks.push(Buffer.from([value === null ? 0 : 1]));
  if (value !== null) text(value);
  const bytes = Buffer.concat(chunks);
  return new Reader(bytes.buffer, bytes.byteOffset, bytes.length);
}

test('named wire attributes preserve empty, false, replacement and removal', () => {
  const attributes = new Map();
  const node = { setAttribute: (name, value) => attributes.set(name, value), removeAttribute: (name) => attributes.delete(name) };
  const page = { nodes: new Map([[1, node]]), meta: new Map([[1, {}]]), relations: new Map() };
  function apply(name, value) {
    const reader = encoded(name, value);
    Page.prototype.attribute.call(page, 1, reader);
    assert.equal(reader.done, true);
  }
  apply('data-empty', '');
  apply('aria-expanded', 'false');
  apply('data-state', 'open');
  apply('data-state', 'closed');
  assert.equal(attributes.get('data-empty'), '');
  assert.equal(attributes.get('aria-expanded'), 'false');
  assert.equal(attributes.get('data-state'), 'closed');
  apply('data-empty', null);
  assert.equal(attributes.has('data-empty'), false);
  apply('data-bad" onclick', 'bad');
  apply('onclick', 'bad');
  assert.equal(attributes.size, 2);
});
