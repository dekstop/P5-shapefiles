// Basic shapefile loading test.
//
// Requires the OpenJUMP libraries. Secifically:
// * OpenJUMP-*.jar
// * log4j-*.jar
// * jts-*.jar
//
// March 2012

import com.vividsolutions.jts.geom.*;
import com.vividsolutions.jump.io.*;
import com.vividsolutions.jump.feature.*;

String filename = "data/London/Main_Roads.shp";

FeatureCollection fc;
List<Feature> features;

float minx, miny, maxx, maxy;
float mapscale;

void setup() {
  
  colorMode(HSB);
  size(800, 600);
  smooth();
  noLoop();
  
  ShapefileReader reader = new ShapefileReader();
  try {
    fc = reader.read(new DriverProperties(filename));
    features = fc.getFeatures();
    println("Found " + features.size() + " features.");
    println("Envelope: " + fc.getEnvelope()); 
    
    println("Total number of fields: " + fc.getFeatureSchema().getAttributeCount());
    for (int i=0;i<fc.getFeatureSchema().getAttributeCount();i++) {
      println("Field name "+ i + ": " + fc.getFeatureSchema().getAttributeName(i));
    }
    
    minx = (float)fc.getEnvelope().getMinX();
    miny = (float)fc.getEnvelope().getMinY();
    maxx = (float)fc.getEnvelope().getMaxX();
    maxy = (float)fc.getEnvelope().getMaxY();
    
    float mwidth = maxx-minx;
    float mheight = maxy-miny;
    float scalex = abs(mwidth)/width;
    float scaley = abs(mheight)/height;
    mapscale = max(scaley,scalex);
    
  } catch (Exception e) {
    e.printStackTrace();
    System.exit(1);
  }
}

void drawShapeFile() {

  // This assumes that all features are polylines
  for (int i=0; i<features.size(); i++) {
    float hue = 0;
    float size = 0.5;
    
    Feature feature = features.get(i);
    Coordinate[] coordinates = feature.getGeometry().getCoordinates();
    Integer maxSpeed = (Integer)feature.getAttribute("maxspeed");
    if (maxSpeed!=null) {
      hue += maxSpeed;
    }
    // tertiary_link, primary_link, tertiary, trunk, primary, secondary, motorway, motorway_link, trunk_link, secondary_link
    String type = (String)feature.getAttribute("type");
    if ("motorway".equals(type)) {
      size += 2;
    }
    
    beginShape();
    for (int j=0; j<coordinates.length; j++) {
      float jpointx = (float)(coordinates[j].x - minx) / mapscale;
      float jpointy = (float)(coordinates[j].y - miny) / mapscale;
      jpointy = height - jpointy; // invert Y axis
      
      strokeWeight(size);
      stroke(hue, 150, 200, 255);
      vertex(jpointx, jpointy);
    }
    endShape();
  }
}

void draw() {
  background(255);
  drawShapeFile();
}
