// === Pocket Bb (13" backpack) – Pull-Toward-Player Lever Kit ===
// Self-contained file. Units: mm
// ---------------- SELECT WHAT TO EXPORT ----------------
PART = "valve_block_pull"; 
// options: bach_receiver | tube_80 | tube_120 | tube_150
//          bend90 | bend135 | bend180
//          cone_valve_body_pull | cone_plug_key
//          lever_pull | spring_leaf | valve_block_pull
//          bell_left | bell_right | preview_assembly

$fn=180;

// --------- Globals ---------
env_w=300; env_d=210; env_h=110;
bore=11.6; wall=2.2; Rmin=52;
taper_ratio=1/60; seatL=20; plugL=22;
lever_travel_deg=60;        // レバー＆プラグの回転角
valve_spacing= seatL+12;    // 3連の間隔

// --------- Basic tubes/bends/receiver ---------
module tube_segment(len,id=bore,t=wall){
  od=id+2*t; difference(){ cylinder(h=len,r=od/2); cylinder(h=len,r=id/2); }
}
module bend(angle=90,r=Rmin,id=bore,t=wall){
  rotate_extrude(angle=angle) translate([r,0,0]) difference(){ circle(r=(id/2)+t); circle(r=id/2); }
}
module bach_receiver(len=40, tip_id=10.5, butt_id=12.0, od=22){
  difference(){ cylinder(h=len, r=od/2);
    cylinder(h=len, r1=tip_id/2, r2=butt_id/2); }
}

// --------- Valve: body with keyway (pull) ---------
module cone_valve_body_pull(body_od=bore+2*wall+10){
  union(){
    // base
    translate([0,0,-5]) difference(){ cylinder(h=5,r=body_od/2); cylinder(h=5,r=(bore/2)+2); }
    // tapered seat + port windows
    difference(){
      cylinder(h=seatL, r=body_od/2);
      cylinder(h=seatL, r1=(bore/2)+2, r2=(bore/2)+2 + seatL*taper_ratio);
      translate([0,0,seatL/2]) rotate([90,0,0]) cylinder(h=body_od, r=(bore/2)+0.25, center=true);
      translate([0,0,seatL/2]) rotate([0,90,0]) cylinder(h=body_od, r=(bore/2)+0.25, center=true);
    }
    // top ring + keyway opening toward +Y（プレイヤー側）
    translate([0,0,seatL]) difference(){
      cylinder(h=6, r=body_od/2);
      cylinder(h=6, r=(bore/2)+2 + seatL*taper_ratio);
      translate([0, +((body_od/2)-6), 3]) rotate([90,0,0]) cube([10,4,6], center=true); // keyway
    }
    // hinge base & stoppers
    translate([ (body_od/2)+6, +6, seatL+3]) cube([12,8,6], center=true); // hinge pad
    for(s=[-1,1]) translate([0, 12*s, seatL+5]) cube([3,4,6], center=true); // 60° stops
    // rubber return posts
    translate([ (body_od/2)+10, -8, seatL+5]) cylinder(h=8, r=1.8, center=true);
    translate([ (body_od/2)+10, +8, seatL+5]) cylinder(h=8, r=1.8, center=true);
  }
}

// --------- Plug with external key ---------
module cone_plug_key(){
  r0=(bore/2)+1.95; r1=r0+plugL*taper_ratio;
  difference(){
    hull(){ translate([0,0,0]) cylinder(h=0.01, r=r0);
           translate([0,0,plugL]) cylinder(h=0.01, r=r1); }
    translate([0,0,plugL/2]) rotate([90,0,0]) cylinder(h=r1*2.6, r=bore/2, center=true);
    translate([0,0,plugL/2]) rotate([0,90,0]) cylinder(h=r1*2.6, r=bore/2, center=true);
  }
  translate([0, r1+4.5, plugL-2]) cube([4,8,3], center=true); // external key (+Y)
}

// --------- Lever (pull-toward-player) ---------
module lever_pull(){
  difference(){
    hull(){ translate([0,0,0]) cylinder(h=6, r=3, center=true);
            translate([-35,0,0]) cylinder(h=6, r=3, center=true); }
    cylinder(h=8, r=1.5, center=true); // hinge φ3
  }
  translate([-35,0,0]) cube([16,12,4], center=true); // finger pad
  translate([-8, 6, 0]) difference(){ cube([14,10,6], center=true);
                                      cube([6,4.2,7], center=true); } // fork
  translate([-20,-8,0]) cylinder(h=8, r=1.8, center=true); // rubber post
}

// --------- Optional spring leaf ---------
module spring_leaf(){
  difference(){ cube([30,8,1.8], center=true);
    translate([-12,0,0]) cylinder(h=3, r=1.5, center=true);
    translate([+12,0,0]) cylinder(h=3, r=1.5, center=true); }
}

// --------- 3-valve block ---------
module valve_block_pull(n=3, sp=seatL+12){
  for(i=[0:n-1]){
    translate([0, i*sp, 0]) cone_valve_body_pull();
    body_od = bore+2*wall+10;
    translate([ (body_od/2)+6, 6 + i*sp, seatL+3]) rotate([0,0,90]) lever_pull();
  }
}

// --------- Big flugel-ish bell (split) ---------
module big_bell(len=190, throat_id=13.0, bell_od=105.0, thk=2.0){
  pts = [[0,throat_id/2],[len*0.50, throat_id/2 + (bell_od/2 - throat_id/2)*0.35],
         [len*0.75, bell_od/2 - 3],[len, bell_od/2]];
  module lathe(rad_pts){ rotate_extrude(angle=360) polygon(points=concat(rad_pts, [[len,0],[0,0]])); }
  difference(){
    lathe(pts);
    translate([0,0,0.1]) rotate_extrude(angle=360)
      polygon(points=concat([ for(p=pts) [p[0], max(0.1,p[1]-thk)] ], [[len,0],[0,0]]));
  }
}
module bell_left(){ intersection(){ big_bell(); translate([-1e3,0,-1e3]) cube([2e3,1e3,2e3]); } }
module bell_right(){ intersection(){ big_bell(); translate([-1e3,-1e3,-1e3]) cube([2e3,1e3,2e3]); } }

// --------- Preview assembly (fit check) ---------
module envelope(){ color([1,0,0,0.08]) translate([-env_w/2,-env_d/2,0]) cube([env_w,env_d,env_h]); }
module preview_assembly(){
  envelope();
  translate([env_w/2 - 36, -20, 20]) valve_block_pull();
  color("gray") translate([env_w/2 - 90, -45, 30]) bach_receiver();
  color("gray") translate([env_w/2 - 100, -20, 20]) rotate([90,0,0]) tube_segment(85);
  color("gray") translate([env_w/2 - 120, 40, 18]) rotate([0,0,180]) bend(180);
  color("gray") translate([env_w/2 - 200, 40, 18]) rotate([0,0,0])   bend(180);
  color("gray") translate([-40, 0, 22]) rotate([90,0,0]) tube_segment(120);
  translate([-120, 0, 35]) rotate([0,90,0]) big_bell();
}

// ---------------- Dispatcher ----------------
if (PART=="bach_receiver")          bach_receiver();
else if (PART=="tube_80")           tube_segment(80);
else if (PART=="tube_120")          tube_segment(120);
else if (PART=="tube_150")          tube_segment(150);
else if (PART=="bend90")            bend(90);
else if (PART=="bend135")           bend(135);
else if (PART=="bend180")           bend(180);
else if (PART=="cone_valve_body_pull")  cone_valve_body_pull();
else if (PART=="cone_plug_key")     cone_plug_key();
else if (PART=="lever_pull")        lever_pull();
else if (PART=="spring_leaf")       spring_leaf();
else if (PART=="valve_block_pull")  valve_block_pull();
else if (PART=="bell_left")         rotate([0,90,0]) bell_left();
else if (PART=="bell_right")        rotate([0,90,0]) bell_right();
else                                preview_assembly();
