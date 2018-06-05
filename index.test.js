/*
 * htl-parser 1.0.0
 * Copyright (c) 2018 Lachlan McDonald
 * https://github.com/lachlanmcdonald/htl-parser/
 *
 * Licensed under the BSD 3-Clause license.
 */
'use strict';

const { parser } = require('./index');

const PassTests = [
	['${}', 'Empty expression'],
	['${}}}', 'Match first closing bracket'],
	'${ a }',
	'${ a && !(b || c) }',
	'${ !a }',
	'${ a && b }',
	'${ a || b }',
	'${ a ? b : c }',
	'${ a < b }',
	'${ a <= b }',
	'${ a == b }',
	'${ a != b }',
	'${ a > b }',
	'${ a >= b }',
	'${ a ? b : c }',
	'${ 123 }',
	'${ 1.23 }',
	'${ 1e5 }',
	'${ 1e+5 }',
	'${ 1e-5 }',
	'${ false }',
	'${ true }',
	'${ "string" }',
	'${ "\\"string" }',
	'${ "\'string\'" }',
	'${ \'string\' }',
	'${ \'\\\'string\' }',
	'${ \'"string"\' }',
	'${ a @ b }',
	'${ a @ b=c }',
	'${ a @ b=true }',
	'${ a @ b=42 }',
	'${ a @ b=\'string\' }',
	'${ a @ b="string" }',
	'${ a @ b=[c, \'string\'] }',
	'${ a @ b=(c && d) || !e }',
	'${ a @ b, c=d, e=\'string\', f=[g, \'string\'] }',
	'${ @ b, c, d }',
	'${ @ b, c, d }',
	'${ a.b.c }',
	'${ a[1][2][3] }',
	'${ [1, 2, 3, true, \'string\', !a, b.c[d]] }',
	'${ [[[[[[[5]]]]]]] }',
	'${ jcr:title }',
	'${ a[b] }'
];

const FailTests = [
	'zzzz',
	'${$}',
	'${{}',
	'${{}}',
	'${ -1 }',
	'${ -1.0 }',
	'${ -.15 }',
	'${ a."string" }'
];

describe('Grammar', () => {
	test('Compiles', () => {
		const fs = require('fs');
		const path = require('path');
		const peg = require('pegjs');

		const grammar = fs.readFileSync(path.join('src', 'htl.pegjs'), 'utf8');
		const parserSource = peg.generate(grammar, {
			cache: false,
			format: 'commonjs',
			optimize: 'speed',
			output: 'source'
		});
	});
});

describe('Smoke tests', () => {
	describe('Parses valid expression', () => {
		PassTests.forEach((x) => {
			const expression = (typeof x === 'string') ? x : x[0];
			const name = (typeof x === 'string') ? x : x[1];

			test(name, () => {
				const tokens = parser.parse(expression);
				expect(tokens).toEqual(expect.anything());
			});
		});
	});

	describe('Throws on invalid expression', () => {
		FailTests.forEach((x) => {
			const expression = (typeof x === 'string') ? x : x[0];
			const name = (typeof x === 'string') ? x : x[1];

			test(name, () => {
				expect(() => {
					parser.parse(expression);
				}).toThrow();
			});
		});
	});
});
