class District {
  final String name;
  final double latitude;
  final double longitude;

  const District(this.name, this.latitude, this.longitude);
}

const List<District> districts = [
  District('Chattogram', 22.3569, 91.7832),
  District('Dhaka', 23.8103, 90.4125),
  District('Rajshahi', 24.3745, 88.6042),
  District('Khulna', 22.8456, 89.5403),
  District('Sylhet', 24.8949, 91.8687),
  District('Barishal', 22.7010, 90.3535),
  District('Rangpur', 25.7439, 89.2752),
  District('Mymensingh', 24.7471, 90.4203),
  District('Cumilla', 23.4607, 91.1809),
  District('Bogura', 24.8465, 89.3776),
];
