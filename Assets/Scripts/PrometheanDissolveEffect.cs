using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer)), RequireComponent(typeof(ParticleSystem))]
public class PrometheanDissolveEffect : MonoBehaviour
{
    public float DissolveUnitsPerSecond = 1;

    private Material material;
    private ParticleSystem particles;
    private Collider coll;

    private bool isDissolving;
    private Vector3 dissolveOrigin;
    private float dissolveTime = 0;
    private ParticleSystem.EmitParams emission;
    private List<Vector4> particleSpawnPoints;

    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
        particles = GetComponent<ParticleSystem>();
        coll = GetComponent<Collider>();

        isDissolving = false;
        particleSpawnPoints = new List<Vector4>();
    }

    void Update()
    {
        if (isDissolving)
        {
            float t = Time.time - dissolveTime;
            float radius = t * DissolveUnitsPerSecond;
            material.SetFloat("_DissolveRadius", radius);

            bool reachedStart = false;
            for (int i = 0; i < particleSpawnPoints.Count; i++)
            {
                var point = particleSpawnPoints[i];
                if (reachedStart)
                {
                    if (point.w > radius + 0.11f)
                    {
                        break;
                    }
                }
                else
                {
                    if (point.w < radius + 0.1)
                    {
                        continue;
                    }
                    reachedStart = true;
                    particleSpawnPoints = particleSpawnPoints.Skip(i).ToList();
                    i = 0;
                }
                emission.position = point;
                particles.Emit(emission, 1);
            }
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

        particleSpawnPoints.Clear();
        float density = 0.15f;
        for (float x = coll.bounds.min.x; x < coll.bounds.max.x; x += density)
        {
            for (float y = coll.bounds.min.y; y < coll.bounds.max.y; y += density)
            {
                for (float z = coll.bounds.min.z; z < coll.bounds.max.z; z += density)
                {
                    var point = coll.ClosestPoint(new Vector3(x, y, z));
                    particleSpawnPoints.Add(new Vector4(point.x, point.y, point.z,
                        Vector3.Distance(dissolveOrigin, point)));
                }
            }
        }
        particleSpawnPoints.Sort((a, b) => (int)Mathf.Sign(a.w - b.w));
    }
}
