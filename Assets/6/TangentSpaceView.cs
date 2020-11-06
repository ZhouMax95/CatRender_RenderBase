using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TangentSpaceView : MonoBehaviour
{
    public float offset = 0.01f;
    public float scale = 0.1f;
    void OnDrawGizmos() {
        MeshFilter filter = GetComponent<MeshFilter>();
        if (filter) {
            Mesh mesh = filter.sharedMesh;
            if (mesh)
            {
                ShowTangentSpace(mesh);
            }
        }

    }

    void ShowTangentSpace(Mesh mesh) {
        Vector3[] vertices = mesh.vertices;
        Vector3[] normal = mesh.normals;
        Vector4[] tangent = mesh.tangents;
        for (int i = 0; i < vertices.Length; i++)
        {
            ShowTangentSpace(
                transform.TransformPoint(vertices[i]),
                transform.TransformDirection(normal[i]),
                transform.TransformDirection(tangent[i]),
                tangent[i].w);
        }
    }

    void ShowTangentSpace(Vector3 vertex, Vector3 normal,Vector3 tangent,float binormalSign) {
        vertex += normal * offset;
        Gizmos.color = Color.green;
        Gizmos.DrawLine(vertex, vertex + normal * scale);
        Gizmos.color = Color.red;
        Gizmos.DrawLine(vertex, vertex + tangent * scale);
        Vector3 binormal = Vector3.Cross(normal, tangent) * binormalSign;
        Gizmos.color = Color.blue;
        Gizmos.DrawLine(vertex, vertex + binormal * scale);
    }
}
