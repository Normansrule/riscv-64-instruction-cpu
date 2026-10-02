// =============================================================================
// web/sevenseg.js: four seven-segment digits drawn in SVG, lit from the DISPLAY register's value
// (one byte per digit, leftmost in bits 31:24; bit 0 = segment a ... bit 6 = g, bit 7 = the decimal
// point), the way fpga/rtl/Seven_Segment_Display.sv lights a Basys 3. Used by the site's FPGA console
// and the lab.
// =============================================================================
// The four digits: segments a..g as polygons, and the decimal point
const SEGMENTS = [ // in a 40 x 72 cell: a, b, c, d, e, f, g
  '6,2 34,2 30,7 10,7', '35,4 35,34 31,31 31,8', '35,38 35,68 31,64 31,41', '6,70 34,70 30,65 10,65',
  '5,38 5,68 9,64 9,41', '5,4 5,34 9,31 9,8', '7,36 11,33 29,33 33,36 29,39 11,39'];
export function buildDisplay(svg) {
  const NS = 'http://www.w3.org/2000/svg', cells = [];
  for (let d = 0; d < 4; d++) { // digit 3 is the leftmost
    const g = document.createElementNS(NS, 'g'); g.setAttribute('transform', `translate(${10 + d * 54},10) skewX(-6)`);
    const segs = SEGMENTS.map(points => { const p = document.createElementNS(NS, 'polygon'); p.setAttribute('points', points); g.appendChild(p); return p; });
    const dot = document.createElementNS(NS, 'circle'); dot.setAttribute('cx', 42); dot.setAttribute('cy', 68); dot.setAttribute('r', 3.2); g.appendChild(dot);
    svg.appendChild(g); cells[3 - d] = [...segs, dot];
  }
  return value => cells.forEach((parts, d) => parts.forEach((el, bit) => el.classList.toggle('on', !!((value >>> (8 * d + bit)) & 1))));
}

