using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[RequireComponent(typeof(MeshFilter)), RequireComponent(typeof(MeshRenderer))]
public class TakenPuddleEffect : MonoBehaviour
{
    [Range(3, 128)]
    public int Sides = 6;

    void Start()
    {
        var filter = GetComponent<MeshFilter>();
        filter.mesh = CreateMesh();
    }

    private Mesh CreateMesh()
    {
        var mesh = new Mesh();
        var vertices = new List<Vector3>();
        var triangles = new List<int>();
        var barycentrics = new List<Vector4>();

        vertices.Add(Vector3.zero);
        barycentrics.Add(Vector3.right);

        float perSide = Mathf.PI * 2f / Sides;
        for (int i = 0; i < Sides; i++)
        {
            float angleA = perSide * i;
            float angleB = perSide * (i + 1);

            vertices.Add(new Vector3(Mathf.Cos(angleA), Mathf.Sin(angleA), 0));
            vertices.Add(new Vector3(Mathf.Cos(angleB), Mathf.Sin(angleB), 0));

            triangles.Add(0);
            triangles.Add((i * 2) + 2);
            triangles.Add((i * 2) + 1);

            barycentrics.Add(Vector3.up);
            barycentrics.Add(Vector3.forward);
        }

        mesh.SetVertices(vertices);
        mesh.SetTriangles(triangles.ToArray(), 0);
        mesh.SetTangents(barycentrics);
        return mesh;
    }
}
