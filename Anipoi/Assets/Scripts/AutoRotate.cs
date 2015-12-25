using UnityEngine;

public class AutoRotate : MonoBehaviour
{
    [Range(0.1f, 5.0f)]
    public float speed = 1.0f;

    void Update()
    {
        transform.Rotate(Vector3.up, speed);
    }
}
