// Edge Function: Notificar al organizador cuando un estudiante se registra
// RF-016: El sistema debe enviar notificaciones a los organizadores cuando alguien se registra en su evento

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { evento_id, estudiante_id } = await req.json()

    // Crear cliente de Supabase con service role (acceso completo)
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // 1. Obtener información del evento y su organizador
    const { data: evento, error: eventoError } = await supabase
      .from('evento')
      .select(`
        nombre,
        id_organizador,
        organizador!inner(
          id_usuario,
          usuario!inner(
            nombre,
            fcm_token
          )
        )
      `)
      .eq('id_evento', evento_id)
      .single()

    if (eventoError || !evento) {
      console.error('Error obteniendo evento:', eventoError)
      return new Response(
        JSON.stringify({ error: 'Evento no encontrado' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. Obtener nombre del estudiante que se registró
    const { data: estudiante, error: estudianteError } = await supabase
      .from('estudiante')
      .select(`
        usuario!inner(nombre, apellido_paterno)
      `)
      .eq('id_estudiante', estudiante_id)
      .single()

    if (estudianteError) {
      console.error('Error obteniendo estudiante:', estudianteError)
    }

    const nombreEstudiante = estudiante?.usuario
      ? `${estudiante.usuario.nombre} ${estudiante.usuario.apellido_paterno}`
      : 'Un estudiante'

    // 3. Obtener FCM token del organizador
    const fcmToken = evento.organizador?.usuario?.fcm_token

    if (!fcmToken) {
      console.log('El organizador no tiene FCM token registrado')
      return new Response(
        JSON.stringify({ message: 'Organizador sin token FCM' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 4. Enviar notificación via FCM
    const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Authorization': `key=${Deno.env.get('FCM_SERVER_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        to: fcmToken,
        notification: {
          title: '¡Nuevo registro!',
          body: `${nombreEstudiante} se registró en "${evento.nombre}"`,
        },
        data: {
          type: 'new_registration',
          evento_id: evento_id,
        },
      }),
    })

    const fcmResult = await fcmResponse.json()
    console.log('FCM Response:', fcmResult)

    return new Response(
      JSON.stringify({ success: true, fcm: fcmResult }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error en función:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
