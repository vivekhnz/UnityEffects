using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateObject : MonoBehaviour
{
    public Vector3 DegreesPerSecond = Vector3.one;

    void Update()
    {
        transform.Rotate(DegreesPerSecond * Time.deltaTime);
    }
}
