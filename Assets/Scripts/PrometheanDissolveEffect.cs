using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer)), RequireComponent(typeof(ParticleSystem))]
public class PrometheanDissolveEffect : MonoBehaviour
{
    public float DissolveUnitsPerSecond = 1;
    public float ParticleFringeWidth = 0.01f;
    public float ParticleSpacing = 0.2f;

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
            // increase dissolve radius over time
            float t = Time.time - dissolveTime;
            float radius = t * DissolveUnitsPerSecond;
            material.SetFloat("_DissolveRadius", radius);

            if (particleSpawnPoints.Count > 0)
            {
                if (particleSpawnPoints.Last().w < radius)
                {
                    particleSpawnPoints.Clear();
                }
                for (int i = 0; i < particleSpawnPoints.Count; i++)
                {
                    // don't spawn particles within the dissolve radius
                    if (particleSpawnPoints[i].w >= radius)
                    {
                        particleSpawnPoints = particleSpawnPoints.Skip(i).ToList();
                        break;
                    }
                }
                foreach (var point in particleSpawnPoints)
                {
                    // don't spawn particles outside of the fringe
                    if (point.w > radius + ParticleFringeWidth)
                    {
                        break;
                    }

                    // randomize particle velocity
                    var direction = new Vector3(
                        Random.Range(-1f, 1f),
                        Random.Range(-1f, 1f),
                        Random.Range(-1f, 1f));
                    emission.velocity = direction * Random.Range(
                        particles.main.startSpeed.constantMin,
                        particles.main.startSpeed.constantMax);
                    emission.angularVelocity3D = direction;

                    // emit particle
                    emission.position = (Vector3)point;
                    particles.Emit(emission, 1);
                }
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

        // determine particle spawn points along mesh
        particleSpawnPoints.Clear();
        for (float x = coll.bounds.min.x; x < coll.bounds.max.x; x += ParticleSpacing)
        {
            for (float y = coll.bounds.min.y; y < coll.bounds.max.y; y += ParticleSpacing)
            {
                for (float z = coll.bounds.min.z; z < coll.bounds.max.z; z += ParticleSpacing)
                {
                    var point = coll.ClosestPoint(new Vector3(x, y, z));
                    particleSpawnPoints.Add(new Vector4(point.x, point.y, point.z,
                        Vector3.Distance(dissolveOrigin, point)));
                }
            }
        }

        // sort particle points by distance to dissolve origin so we can skip points outside
        // of the dissolve radius
        particleSpawnPoints.Sort((a, b) => (int)Mathf.Sign(a.w - b.w));
    }
}
