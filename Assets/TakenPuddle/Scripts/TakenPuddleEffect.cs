using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[RequireComponent(typeof(MeshFilter)), RequireComponent(typeof(MeshRenderer))]
public class TakenPuddleEffect : MonoBehaviour
{
    [Range(3, 128)]
    public int Sides = 6;

    public float MinBloomIntensity = 1;
    public float MaxBloomIntensity = 2;
    public float MinBloomIntensityRange = 5;
    public float MaxBloomIntensityRange = 3;

    private BloomEffect bloom;

    void Start()
    {
        var filter = GetComponent<MeshFilter>();
        filter.mesh = CreateMesh();

        bloom = Camera.main.GetComponent<BloomEffect>();
    }

    /// <summary>
    /// Update is called every frame, if the MonoBehaviour is enabled.
    /// </summary>
    void Update()
    {
        if (bloom != null)
        {
            // calculate bloom intensity based on distance to camera
            float distance = Vector3.Distance(transform.position,
                Camera.main.transform.position);
            float rangeDiff = MaxBloomIntensityRange - MinBloomIntensityRange;
            float intensity = ((distance - MaxBloomIntensityRange) / rangeDiff) + 1;
            float clamped = Mathf.Clamp(intensity, 0, 1);
            bloom.SetPerFrameIntensity(
                Mathf.Lerp(MinBloomIntensity, MaxBloomIntensity, clamped));
        }
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

            if (i % 2 == 0)
            {
                barycentrics.Add(Vector3.up);
                barycentrics.Add(Vector3.forward);
            }
            else
            {
                barycentrics.Add(Vector3.forward);
                barycentrics.Add(Vector3.up);
            }
        }

        mesh.SetVertices(vertices);
        mesh.SetTriangles(triangles.ToArray(), 0);
        mesh.SetTangents(barycentrics);
        return mesh;
    }
}
