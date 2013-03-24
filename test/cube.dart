part of test_model;

const String cubeMesh =
'''
{
   "rootnode": {
     "name": "box.obj"
    ,"transformation": [
       1
      ,0
      ,0
      ,0
      ,0
      ,1
      ,0
      ,0
      ,0
      ,0
      ,1
      ,0
      ,0
      ,0
      ,0
      ,1
    ]
    ,"children": [
      {
         "name": "1"
        ,"transformation": [
           1
          ,0
          ,0
          ,0
          ,0
          ,1
          ,0
          ,0
          ,0
          ,0
          ,1
          ,0
          ,0
          ,0
          ,0
          ,1
        ]
        ,"meshes": [
           0
        ]
      }
    ]
  }
  ,"flags": 8
  ,"meshes": [
    {
       "name": ""
      ,"materialindex": 0
      ,"primitivetypes": 4
      ,"vertices": [
         -0.5
        ,0.5
        ,0.5
        ,-0.5
        ,0.5
        ,-0.5
        ,-0.5
        ,-0.5
        ,-0.5
        ,-0.5
        ,-0.5
        ,0.5
        ,0.5
        ,-0.5
        ,-0.5
        ,0.5
        ,-0.5
        ,0.5
        ,0.5
        ,0.5
        ,-0.5
        ,0.5
        ,0.5
        ,0.5
      ]
      ,"normals": [
         -0.57735
        ,0.57735
        ,0.57735
        ,-0.57735
        ,0.57735
        ,-0.57735
        ,-0.57735
        ,-0.57735
        ,-0.57735
        ,-0.57735
        ,-0.57735
        ,0.57735
        ,0.57735
        ,-0.57735
        ,-0.57735
        ,0.57735
        ,-0.57735
        ,0.57735
        ,0.57735
        ,0.57735
        ,-0.57735
        ,0.57735
        ,0.57735
        ,0.57735
      ]
      ,"faces": [
        [
           0
          ,1
          ,2
        ]
        ,[
           0
          ,2
          ,3
        ]
        ,[
           2
          ,4
          ,5
        ]
        ,[
           2
          ,5
          ,3
        ]
        ,[
           1
          ,6
          ,4
        ]
        ,[
           1
          ,4
          ,2
        ]
        ,[
           7
          ,6
          ,1
        ]
        ,[
           7
          ,1
          ,0
        ]
        ,[
           5
          ,7
          ,0
        ]
        ,[
           5
          ,0
          ,3
        ]
        ,[
           4
          ,6
          ,7
        ]
        ,[
           4
          ,7
          ,5
        ]
      ]
    }
  ]
  ,"materials": [
    {
       "properties": [
        {
           "key": "?mat.name"
          ,"semantic": 0
          ,"index": 0
          ,"type": 3
          ,"value": "DefaultMaterial"
        }
        ,{
           "key": "\$mat.shadingm"
          ,"semantic": 0
          ,"index": 0
          ,"type": 4
          ,"value": 2
        }
        ,{
           "key": "\$clr.ambient"
          ,"semantic": 0
          ,"index": 0
          ,"type": 1
          ,"value": [
             0
            ,0
            ,0
          ]
        }
        ,{
           "key": "\$clr.diffuse"
          ,"semantic": 0
          ,"index": 0
          ,"type": 1
          ,"value": [
             0.6
            ,0.6
            ,0.6
          ]
        }
        ,{
           "key": "\$clr.specular"
          ,"semantic": 0
          ,"index": 0
          ,"type": 1
          ,"value": [
             0
            ,0
            ,0
          ]
        }
        ,{
           "key": "\$mat.shininess"
          ,"semantic": 0
          ,"index": 0
          ,"type": 1
          ,"value": 0
        }
        ,{
           "key": "\$mat.opacity"
          ,"semantic": 0
          ,"index": 0
          ,"type": 1
          ,"value": 1
        }
        ,{
           "key": "\$mat.refracti"
          ,"semantic": 0
          ,"index": 0
          ,"type": 1
          ,"value": 1
        }
      ]
    }
  ]
}
''';


