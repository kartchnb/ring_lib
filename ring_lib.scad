// Calculate the usable height of the ring
function RingLib_FlatHeight(thickness=1, height=1) =
    let
    (
        flat_height = height - thickness
    )
    flat_height;



function RingLib_ExpansionAmount(thickness=1, height=1, expansion_factor=0) =
    let
    (
        expansion_percent = expansion_factor/100,
        flat_height = RingLib_FlatHeight(thickness, height),
        expansion_amount = (height / 2 - thickness / 2) * expansion_percent
    )
    expansion_amount;


function RingLib_OutsideDiameter(inside_diameter=1, height=1, thickness=1, expansion_factor=0) =
    let
    (
        expansion_amount = RingLib_ExpansionAmount(thickness, height, expansion_factor),
        outside_diameter = inside_diameter + thickness*2 + expansion_amount*2
    )
    outside_diameter;



// Generate a model of a ring with the given parameters
module RingLib_Generate(inside_diameter=1, thickness=1, height=1, expansion_factor=0, facets=0, rotation_angle=360)
{
    // A small amount used to avoid rounding errors in difference operations
    iota = 0.001;

    default_fn = $fn;
    ring_fn = (facets >= 3 ? facets: $fn);

    flat_height = RingLib_FlatHeight(thickness, height);
    expansion_amount = RingLib_ExpansionAmount(thickness, height, expansion_factor);



    // Generate the ring cross section
    module GenerateCrossSection()
    {
        translate([thickness / 2, 0, 0])
        {
            // Generate the basic cross-section
            hull()
            {
                for (y_offset = [-height / 2 + thickness / 2, height / 2 - thickness / 2])
                translate([0, y_offset])
                    circle(d=thickness);
            }

            if (expansion_amount > 0)
            {
                // Calculate the angle at which the expansion circle meets the ring edge circle
                mating_angle = 90 * expansion_factor / 100;

                // Calculate the radius of the expansion circle
                radius = (flat_height / (2 * sin(mating_angle))) + thickness / 2;

                // Calculate the x offset of the center of the expansion circle
                expansion_x_offset = -(flat_height / 2) / tan(mating_angle);

                // Calculate the x offset of the intersection box
                intersection_x_offset = thickness / 2 * cos(mating_angle);

                intersection()
                {
                    translate([expansion_x_offset, 0])
                        circle(r=radius, $fn=default_fn);

                    translate([intersection_x_offset, -height / 2])
                        square([(thickness + expansion_amount) * 2, height]);
                }
            }
        }
    }



    rotate_extrude(angle=rotation_angle, $fn=ring_fn)
    translate([inside_diameter / 2, 0])
        GenerateCrossSection();
}
