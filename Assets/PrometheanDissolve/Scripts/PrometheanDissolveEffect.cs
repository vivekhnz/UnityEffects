using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class PrometheanDissolveEffect : MonoBehaviour
{
    public float DissolveUnitsPerSecond = 1;
    public float ParticleFringeOffset = 0.0f;
    public float ParticleFringeWidth = 0.5f;
    public Material DissolveMaterial;
    public Transform OuterSphere;
    public Transform InnerSphere;

    private Material material;
    private ParticleSystem particles;

    private float dissolveTime = 0;
    private Vector3 parentScale;
    private float maxRadius;
    private GameObject target;

    void Awake()
    {
        particles = GetComponent<ParticleSystem>();
    }

    void Update()
    {
        // increase dissolve radius over time
        float t = Time.time - dissolveTime;
        float radius = t * DissolveUnitsPerSecond;
        material.SetFloat("_DissolveRadius", radius);

        // adjust trigger sphere scales
        float outerRadius = radius + ParticleFringeOffset;
        float innerRadius = outerRadius - ParticleFringeWidth;
        OuterSphere.localScale = new Vector3(outerRadius / parentScale.x,
            outerRadius / parentScale.y, outerRadius / parentScale.z);
        InnerSphere.localScale = new Vector3(innerRadius / parentScale.x,
            innerRadius / parentScale.y, innerRadius / parentScale.z);

        // destroy target after radius has exceeded its bounds
        if (radius > maxRadius)
        {
            Destroy(target);
        }
    }

    public void DissolveTarget(Transform target, Vector3 dissolvePoint)
    {
        // disable target's colliders
        this.target = target.gameObject;
        var colliders = target.GetComponentsInChildren<Collider>();
        foreach (var collider in colliders)
        {
            collider.enabled = false;
        }

        // attach to target
        transform.SetParent(target);
        material = new Material(DissolveMaterial);
        transform.localScale = Vector3.one;
        transform.position = target.position;
        parentScale = target.lossyScale;

        // retrieve target mesh
        var skinnedMeshRenderer = target.GetComponent<SkinnedMeshRenderer>();
        var shape = particles.shape;
        if (skinnedMeshRenderer == null)
        {
            shape.shapeType = ParticleSystemShapeType.Mesh;
            shape.mesh = target.GetComponent<MeshFilter>().mesh;
        }
        else
        {
            shape.shapeType = ParticleSystemShapeType.SkinnedMeshRenderer;
            shape.skinnedMeshRenderer = skinnedMeshRenderer;
        }

        // initialize material
        var renderer = target.GetComponent<Renderer>();
        renderer.material = material;
        dissolveTime = Time.time;
        maxRadius = Mathf.Max(renderer.bounds.size.x, renderer.bounds.size.y,
            renderer.bounds.size.z) * 2;
        material.SetVector("_DissolveOrigin", dissolvePoint);

        // initialize trigger spheres
        OuterSphere.transform.position = dissolvePoint;
        OuterSphere.transform.localScale = Vector3.zero;
        InnerSphere.transform.position = dissolvePoint;
        InnerSphere.transform.localScale = Vector3.zero;
    }
}
