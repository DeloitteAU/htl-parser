/*
 * htl-parser 1.0.0
 * Copyright (c) 2018 Lachlan McDonald
 * https://github.com/lachlanmcdonald/htl-parser/
 *
 * Licensed under the BSD 3-Clause license.
 */
'use strict';

const { parser } = require('./index');

describe('Smoke tests', () => {
	test('Parses valid expression', () => {
		const tokens = parser.parse('${ a || b }');
		expect(tokens).toEqual(expect.anything());
	});

	test('Throws on invalid expression', () => {
		expect(() => {
			parser.parse('invalid');
		}).toThrow();
	});
});
