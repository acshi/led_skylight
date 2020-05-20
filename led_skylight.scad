heatsink_w = 61;
heatsink_l = 58;
heatsink_h = 23.88;

plywood_t = 2.921; // actually lets use 0.115" hardboard
box_h = 200;//heatsink_h + 80;
mount_hole_offset = 9.7/2;

// besides using various slits to piece things together
// we can also drill various 45 degree angled holes where the boards
// make butt joints, and then use a bamboo skewer as a reinforcement there
// which if it makes a relatively snug fit can work while still being removable
// I'm thinking we would only do this for the exterior joints
// since the interior connections can all be loose and non-structural

module heatsink_pcb() {
    color("gray")
    difference() {
        cube([heatsink_w, heatsink_l, heatsink_h]);
        translate([9.7/2, 9.7/2, -0.01])
            cylinder(r=1.6, h=100); 
        translate([61-9.7/2, 9.7/2, -0.01])
            cylinder(r=1.6, h=100); 
        translate([9.7/2, 58-9.7/2, -0.01])
            cylinder(r=1.6, h=100); 
        translate([61-9.7/2, 58-9.7/2, -0.01])
            cylinder(r=1.6, h=100); 
    }
    color("green")
    translate([1.5, 6, -0.6]) 
        cube([58, 44, 0.6]);
    // spreading cone of light
    cone_h = 4000;
    *translate([heatsink_w/2, heatsink_l/2, -0.6]) rotate([0, 180, 0])
        %cylinder(h=cone_h, r1=2,  r2=cone_h*sin(13.5)+2);
}

power_supply_l = 220.2;
power_supply_w=68;
power_supply_t=38.8;
module power_supply() {
    color("silver")
    translate([-110.1, 0, 0]) {
        difference() {
            union() {
                cube([power_supply_l, power_supply_w, power_supply_t]);
                translate([-12, (68-53)/2, 0]) cube([244.2, 53, 3.0]);
            }
            for (xi = [0 : 4]) {
                translate([-2.4-2.1-xi*1.75, (68-53)/2+9.4, -0.1])
                    cylinder(d=4.2, h=10);
                translate([-2.4-2.1-xi*1.75, (68-53)/2+9.4+34.2, -0.1])
                    cylinder(d=4.2, h=10);
                translate([2.4+2.1+220.2+xi*1.75, (68-53)/2+9.4, -0.1])
                    cylinder(d=4.2, h=10);
                translate([2.4+2.1+220.2+xi*1.75, (68-53)/2+9.4+34.2, -0.1])
                    cylinder(d=4.2, h=10);
            }
        }
    }
}

module skylight() {
    gap = 42;
    x_stride = 61 + gap;
    y_stride = 58 + gap;
    power_gap = power_supply_w-plywood_t-6;

    translate([gap/2+plywood_t/2, gap/2+plywood_t/2, heatsink_h])
    for (yi = [0 : 3]) {
        for (xi = [0 : 3]) {
            y = yi * y_stride + (yi > 1 ? power_gap: 0);
            translate([xi * x_stride, y, 0])
            heatsink_pcb();
        }
    }
    
    pcb_mount_t = 12;
    
    exterior_slit_h = 50;
    interior_slit_h = box_h / 2;
    slit_t = plywood_t*2;
    slit_off = (slit_t - plywood_t)/2;

    total_width = x_stride * 4 + plywood_t;
    total_length = y_stride * 4 + plywood_t + power_gap;
    translate([0, 0, -box_h + heatsink_h]) {
        for (xi = [0 : 4]) {
            translate([xi * x_stride, 0, 0])
            difference() {
                cube([plywood_t, total_length, box_h]);
                // everything below here are the various slits for fitting the pieces together
                for (yi = [0 : 5]) {
                    y = yi * y_stride + (yi > 2 ? power_gap - y_stride: 0);
                    if ((xi == 0 || xi == 4) && yi > 0 && yi < 5) {
                        translate([-0.01-slit_off, y - 0.01-slit_off, box_h - exterior_slit_h])
                        #cube([slit_t+0.02, slit_t + 0.02, exterior_slit_h]);
                    } else if (xi > 0 && xi < 5) {
                        if (yi > 0 && yi < 5) {
                            translate([-0.01-slit_off, y - 0.01-slit_off, 0.0])
                            #cube([slit_t+0.02, slit_t + 0.02, interior_slit_h]);
                        } else {
                            translate([-0.01, y - 0.01, 0.0])
                            #cube([plywood_t+0.02, plywood_t + 0.02, box_h - exterior_slit_h]);
                        }
                    }
                }
            }
        }
        //translate([0, 600, 0])
        for (yi = [0 : 5]) {
            y = yi * y_stride + (yi > 2 ? power_gap - y_stride: 0);
            translate([0, y, 0])
            difference() {
                cube([total_width, plywood_t, box_h]);
                // everything below here are the various slits for fitting the pieces together
                for (xi = [0 : 4]) {
                    translate([xi * x_stride + 0.01, 0.01, 0])
                    if ((yi == 0 || yi == 5) && xi > 0 && xi < 4) {
                        translate([-slit_off, -slit_off, box_h - exterior_slit_h])
                        #cube([slit_t + 0.02, slit_t + 0.02, exterior_slit_h]);
                    } else if ((yi == 0 || yi == 5) && (xi == 0 || xi == 4)) {
                        #cube([plywood_t + 0.02, plywood_t + 0.02, box_h]);
                    } else if (yi > 0 && yi < 5 && xi > 0 && xi < 4) {
                        translate([-slit_off, -slit_off, box_h - interior_slit_h])
                        #cube([slit_t + 0.02, slit_t + 0.02, box_h - interior_slit_h]);
                    } else if (yi > 0 && yi < 5) {
                        #cube([plywood_t + 0.02, plywood_t + 0.02, box_h - exterior_slit_h]);
                    }
                }
            }
            *if (yi != 5 && yi != 2) {
                translate([0, y+gap/2+mount_hole_offset, box_h-pcb_mount_t])
                    cube([total_width, plywood_t, pcb_mount_t]);
            }
            *if (yi != 0 && yi != 3) {
                translate([0, y-gap/2-mount_hole_offset, box_h-pcb_mount_t])
                    cube([total_width, plywood_t, pcb_mount_t]);
            }
        }
    }
    
    translate([total_width/2,
                         total_length/2-power_supply_w/2,
                         power_supply_t/2+4])
    rotate([0, 0, 0])
        power_supply();
    
    echo("Dimensions: ", total_width, "mm",  total_length, "mm");
    echo("Dimensions: ", total_width / 25.4, "inches",  total_length / 25.4, "inches");
}
skylight();