const detailed_space_types = OrderedDict{Int64,String}(
    1=>"Building Support - Other",                  2=>"Building Support - Mechanical Room",
    3=>"Building Support - Garbage",                4=>"Building Support - Electrical",
    5=>"Building Support - Mechnical Mezzanine",    6=>"Process - Other",
    7=>"Process - Stage/Backstage",                 8=>"Process - Kitchen",
    9=>"Process - Food Prep (Deli/Bakery/Meat)",    10=>"Process - Repair/Service Area",
    11=>"Process - Medical Exam",                   12=>"Process - Medical Procedure",
    13=>"Process - Data Center",                    14=>"Process - Laboratory",
    15=>"Process - Laundry/Housekeeping",           16=>"Public Access - Other",
    17=>"Public Access - Auditorium",               18=>"Public Access - Seating Area",
    19=>"Public Access - Dining",                   20=>"Public Access - Playing/Court Area",
    21=>"Public Access - Gym",                      22=>"Public Access - Locker Room",
    23=>"Public Access - Stacks",                   24=>"Public Access - Reading/Computer Room",
    25=>"Public Access - Multipurpose Room",        26=>"Public Access - Sales",
    27=>"Public Access - Gallery",                  28=>"Storage - All",
    29=>"Refrigerated Storage - All",               30=>"Parking - All",
    31=>"Exterior - Other",                         32=>"Exterior - Building Façade",
    33=>"Exterior - Walkways",                      34=>"Exterior - Open Air Parking",
    35=>"Office/Classroom - Other",                 36=>"Office/Classroom - Open Office",
    37=>"Office/Classroom - Enclosed Office",       38=>"Office/Classroom - Meeting/Conference Room",
    39=>"Office/Classroom - Classroom",             40=>"Common Areas - Other",
    41=>"Common Areas - Lobby",                     42=>"Common Areas - Corridor",
    43=>"Common Areas - Restroom",                  44=>"Common Areas - Stairwell",
    45=>"Living Quarters - Other",                  46=>"Living Quarters - Dwelling Unit",
    47=>"Living Quarters - Guest Room",             48=>"Living Quarters - Patient Room",
    49=>"Unknown - All",                            50=>"_Walls/Windows/Doors/Etc"
)

const dd_opts = collect(values(detailed_space_types))
