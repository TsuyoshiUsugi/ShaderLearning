using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeColor : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        GetComponent<Renderer> ().material.SetColor ("_BaseColor", Color.blue);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
