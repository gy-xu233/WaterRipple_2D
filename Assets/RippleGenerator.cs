using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RippleGenerator : MonoBehaviour
{
    // Start is called before the first frame update

    public Material mat;
    private int counter = 0;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (counter < 1)
        {
            mat.SetInt("_Counter", 0);
            counter++;
        }
        else
            mat.SetInt("_Counter", 1);
        if(Input.GetMouseButtonDown(0))
        {
            mat.SetInt("_IfClick", 1);
            Vector4 mousePos = new Vector4(Input.mousePosition.x, Input.mousePosition.y, 1, 0);
            mat.SetVector("iMouse", new Vector4(mousePos.x, mousePos.y, 1, 0));
        }
        else
        {
            mat.SetInt("_IfClick", 0);
            
        }
    }
}
