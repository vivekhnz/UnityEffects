using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement2D : MonoBehaviour
{
    public float Speed = 0.1f;

    private Animator animator;
    private SpriteRenderer sprite;

    /// <summary>
    /// Start is called on the frame when a script is enabled just before
    /// any of the Update methods is called the first time.
    /// </summary>
    void Start()
    {
        animator = GetComponent<Animator>();
        sprite = GetComponent<SpriteRenderer>();
    }

    /// <summary>
    /// Update is called every frame, if the MonoBehaviour is enabled.
    /// </summary>
    void Update()
    {
        // move based on input
        float movement = Input.GetAxis("Horizontal");
        float absMovement = Mathf.Abs(movement);
        transform.Translate(movement * Speed, 0, 0);

        // update sprite
        animator.SetFloat("WalkSpeed", absMovement);
        if (absMovement > 0)
        {
            sprite.flipX = movement < 0;
        }
    }
}
