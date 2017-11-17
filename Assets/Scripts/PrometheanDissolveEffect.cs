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

    private Material material;
    private Material particleMaterial;
    private SerializedObject particlesRef;

    private bool isDissolving;
    private Vector3 dissolveOrigin;
    private float dissolveTime = 0;

    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
        var mesh = GetComponent<MeshFilter>().sharedMesh;

        var particles = GetComponent<ParticleSystem>();
        particlesRef = new SerializedObject(particles);
        particlesRef.FindProperty(PARTICLES_SHAPE_MESH).objectReferenceValue = mesh;
        particlesRef.ApplyModifiedProperties();
        particleMaterial = particles.GetComponent<ParticleSystemRenderer>().material;

        isDissolving = false;
    }

    void Update()
    {
        if (isDissolving)
        {
            float t = Time.time - dissolveTime;
            float radius = t * DissolveUnitsPerSecond;
            material.SetFloat("_DissolveRadius", radius);
            particleMaterial.SetFloat("_DissolveRadius", radius);
        }
        else
        {
            material.SetFloat("_DissolveRadius", 0);
            particleMaterial.SetFloat("_DissolveRadius", 0);
        }
    }

    public void DissolveFrom(Vector3 origin)
    {
        dissolveTime = Time.time;
        isDissolving = true;
        dissolveOrigin = origin;

        material.SetVector("_DissolveOrigin", dissolveOrigin);
        particleMaterial.SetVector("_DissolveOrigin", dissolveOrigin);
        particlesRef.FindProperty(PARTICLES_SHAPE_POSITION).vector3Value =
            transform.worldToLocalMatrix.MultiplyPoint(dissolveOrigin);
    }
}
