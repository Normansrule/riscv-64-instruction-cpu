# =============================================================================
# tools/render_cell.py: draw a SkyWater sky130 standard cell layout (GDS) as SVG
#
#   curl -sLO https://raw.githubusercontent.com/efabless/skywater-pdk-libs-sky130_fd_sc_hd/master/cells/xor2/sky130_fd_sc_hd__xor2_1.gds
#   python3 tools/render_cell.py sky130_fd_sc_hd__xor2_1.gds docs/img/silicon/cell_xor2.svg "XOR2"
# Needs: pip install gdstk.  Cell layouts: SkyWater PDK, Apache License 2.0.
# =============================================================================
import gdstk, sys
# SkyWater sky130 GDS layer numbers (layer, datatype) -> (name, color, opacity)
LAYERS = [
  ((64,20), 'nwell',  '#E8E0C8', 0.55),
  ((65,20), 'diff',   '#4CAF50', 0.70),
  ((65,44), 'tap',    '#2E7D32', 0.70),
  ((66,20), 'poly',   '#D32F2F', 0.75),
  ((66,44), 'licon1', '#212121', 0.90),
  ((67,20), 'li1',    '#1976D2', 0.45),
  ((67,44), 'mcon',   '#0D47A1', 0.95),
  ((68,20), 'met1',   '#8E24AA', 0.35),
]
def render(path, out, title):
    lib = gdstk.read_gds(path)
    top = [c for c in lib.top_level()][0]
    polys = top.get_polygons()
    bb = top.bounding_box()
    (x0,y0),(x1,y1) = bb
    S = 220  # px per um
    W, H = (x1-x0)*S, (y1-y0)*S
    pad, head, legend_h = 20, 50, 70
    svgW, svgH = W + 2*pad, H + head + legend_h + pad
    o = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {svgW:.0f} {svgH:.0f}" width="{svgW:.0f}">',
         f'<rect width="100%" height="100%" rx="10" fill="#FBFCF8" stroke="#D5DBD0"/>',
         f'<text x="{pad}" y="28" font-family="Helvetica,Arial,sans-serif" font-size="16" font-weight="600" fill="#17251D">{title}</text>',
         f'<text x="{pad}" y="44" font-family="Helvetica,Arial,sans-serif" font-size="11" fill="#4A5A50">{top.name} · {x1-x0:.2f} um x {y1-y0:.2f} um · SkyWater SKY130 (Apache-2.0)</text>',
         f'<g transform="translate({pad},{head+H}) scale({S},{-S}) translate({-x0},{-y0})">']
    for (ly,dt),name,col,op in LAYERS:
        for p in polys:
            if p.layer==ly and p.datatype==dt:
                pts=" ".join(f"{x:.3f},{y:.3f}" for x,y in p.points)
                o.append(f'<polygon points="{pts}" fill="{col}" fill-opacity="{op}" stroke="{col}" stroke-width="0.004"/>')
    o.append('</g>')
    lx, ly0 = pad, head+H+22
    for i,((l,d),name,col,op) in enumerate(LAYERS):
        x = lx + (i%4)*((svgW-2*pad)/4); y = ly0 + (i//4)*22
        o.append(f'<rect x="{x}" y="{y-11}" width="14" height="14" fill="{col}" fill-opacity="{op}" stroke="{col}"/>')
        o.append(f'<text x="{x+20}" y="{y}" font-family="Helvetica,Arial,sans-serif" font-size="11" fill="#17251D">{name} ({l}/{d})</text>')
    o.append('</svg>')
    open(out,'w').write("\n".join(o))
    print(out, f"{x1-x0:.2f}x{y1-y0:.2f}um")
render(sys.argv[1], sys.argv[2], sys.argv[3])
