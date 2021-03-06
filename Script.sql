-- Create table with spatial column
CREATE TABLE mytable (
  id SERIAL PRIMARY KEY,
  geom GEOMETRY(Point, 26910),
  name VARCHAR(128)
);

CREATE TABLE pols (
  id SERIAL PRIMARY KEY,
  pol GEOMETRY(Polygon, 26910),
  name VARCHAR(128)
);

-- Add a spatial index
CREATE INDEX mytable_gix
  ON mytable
  USING GIST (geom);
 
-- Add a point
INSERT INTO mytable (geom, name) VALUES (
  ST_GeomFromText('POINT(2 2)', 26910), 2
);
INSERT INTO mytable (geom, name) VALUES (
  'POINT(2 2)', 2
);
 
-- Add a point
INSERT INTO pols (pol, name) VALUES (
  ST_GeomFromText('POLYGON((3 3,3 0.5,0.5 0.5,0.5 3,3 3))', 26910), 3
);
INSERT INTO mytable (geom, name) VALUES (
  ST_GeomFromText('POLYGON((0 0,4 0,4 4,0 4,0 0),(1 1, 2 1, 2 2, 1 2,1 1))', 26910), 3
);

-- Query for nearby points
SELECT id, name
FROM mytable
WHERE ST_DWithin(
  geom,
  ST_GeomFromText('POINT(1 1.5)', 26910),
  1.5
);

select st_distance(
(SELECT geom
FROM mytable
WHERE name = '1'),
(SELECT geom
FROM mytable
WHERE name = '2'));

select id, name from mytable where st_within(geom, (select pol from pols));


---test
CREATE TABLE gnLands (
  id SERIAL PRIMARY KEY,
  geom GEOMETRY(Point, 4326),
  pnu VARCHAR(19)
);

CREATE INDEX gnLands_gix
  ON gnLands
  USING GIST (geom);

select id, pnu
FROM gnlands
WHERE ST_DWithin(
  geom,
  ST_GeomFromText('POINT(127.06230804789996 37.50839784542325)', 4326),
  0.003
);

select id, pnu
FROM gnlands
WHERE st_within(
  geom,
  ST_GeomFromText('POLYGON((127.06230804789996 37.50839784542325,127.06408046412909 37.50454960590649,127.05752094076199 37.504643082641756,127.06230804789996 37.50839784542325))', 4326)
);

select id, pnu
FROM gnlands
WHERE st_contains(
  ST_GeomFromText('POLYGON((127.06230804789996 37.50839784542325,127.06408046412909 37.50454960590649,127.05752094076199 37.504643082641756,127.06230804789996 37.50839784542325))', 4326),
  geom
);

select id, pnu
FROM gnlands
WHERE st_contains(
  ST_GeomFromText(
  'POLYGON((127.06230804789996 37.50839784542325,127.06408046412909 37.50454960590649,127.05752094076199 37.504643082641756,127.06230804789996 37.50839784542325), 
  (127.06249970569665 37.50765892027005,127.06193265190872 37.50578512861986,127.0600557905906 37.506497891726646,127.06249970569665 37.50765892027005))', 4326),
  geom
);

---test without index
CREATE TABLE gnLands2 (
  id SERIAL PRIMARY KEY,
  geom GEOMETRY(Point, 4326),
  pnu VARCHAR(19)
);

select id,pnu
FROM gnlands2
WHERE ST_DWithin(
  geom,
  ST_GeomFromText('POINT(127.06230804789996 37.50839784542325)', 4326),
  0.003
);

select id, pnu
FROM gnlands2
WHERE st_within(
  geom,
  ST_GeomFromText('POLYGON((127.06230804789996 37.50839784542325,127.06408046412909 37.50454960590649,127.05752094076199 37.504643082641756,127.06230804789996 37.50839784542325))', 4326)
);

select id, pnu
FROM gnlands2
WHERE st_contains(
  ST_GeomFromText('POLYGON((127.06230804789996 37.50839784542325,127.06408046412909 37.50454960590649,127.05752094076199 37.504643082641756,127.06230804789996 37.50839784542325))', 4326),
  geom
);


