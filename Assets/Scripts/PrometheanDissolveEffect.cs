using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(ParticleSystem))]
public class PrometheanDissolveEffect : MonoBehaviour
{
    const string PARTICLES_SHAPE_MESH = "ShapeModule.m_Mesh";
    const string PARTICLES_SHAPE_POSITION = "ShapeModule.m_Position";

    public float DissolveUnitsPerSecond = 1;
    public Mesh SphereMesh;

    private Material material;
    private Mesh baseMesh;
    private SerializedObject particlesRef;

    private bool isDissolving;
    private Vector3 dissolveOrigin;
    private float dissolveTime = 0;

    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
        baseMesh = GetComponent<MeshFilter>().sharedMesh;
        particlesRef = new SerializedObject(GetComponent<ParticleSystem>());

        isDissolving = false;
    }

    void Update()
    {
        if (isDissolving)
        {
            float t = Time.time - dissolveTime;
            float radius = t * DissolveUnitsPerSecond;
            material.SetFloat("_DissolveRadius", radius);
            UpdateParticleMesh(RebuildParticleMesh(radius));
        }
        else
        {
            material.SetFloat("_DissolveRadius", 0);
        }
    }

    public void DissolveFrom(Vector3 origin)
    {
        dissolveTime = Time.time;
        isDissolving = true;
        dissolveOrigin = origin;

        material.SetVector("_DissolveOrigin", dissolveOrigin);
    }

    private Mesh RebuildParticleMesh(float radius)
    {
        Mesh sphere = new Mesh();

        List<Vector3> verts = new List<Vector3>();
        SphereMesh.GetVertices(verts);
        sphere.SetVertices(verts.Select(v => v * radius).ToList());

        List<Vector3> normals = new List<Vector3>();
        SphereMesh.GetNormals(normals);
        sphere.SetNormals(normals);

        sphere.SetTriangles(SphereMesh.GetTriangles(0), 0);

        return sphere;
    }

    private void UpdateParticleMesh(Mesh mesh)
    {
        particlesRef.FindProperty(PARTICLES_SHAPE_MESH).objectReferenceValue = mesh;
        particlesRef.FindProperty(PARTICLES_SHAPE_POSITION).vector3Value =
            transform.worldToLocalMatrix.MultiplyPoint(dissolveOrigin);
        particlesRef.ApplyModifiedProperties();
    }
}
