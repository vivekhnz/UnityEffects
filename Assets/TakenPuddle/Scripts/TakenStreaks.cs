using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class TakenStreaks : MonoBehaviour
{
    private ParticleSystem system;
    private ParticleSystemRenderer particleRenderer;

    void Start()
    {
        system = GetComponent<ParticleSystem>();
        particleRenderer = system.GetComponent<ParticleSystemRenderer>();

        particleRenderer.material.SetVector("_Origin", transform.position);
        particleRenderer.material.SetFloat("_Radius", system.shape.radius);
    }
}
