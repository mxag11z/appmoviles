// Edge Function: Enviar recordatorios de eventos próximos
// RF-015: El sistema debe enviar notificaciones push a los usuarios para recordarles eventos próximos
// Soporta: 30 min, 15 min, 10 min, 1 hora, 1 día antes

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parámetro opcional: minutos antes del evento (default: 30)
    const { minutes_before = 30 } = await req.json().catch(() => ({}))

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Calcular el rango de tiempo
    const now = new Date()
    const targetTime = new Date(now.getTime() + minutes_before * 60 * 1000)

    // Formato para comparar: fecha y hora
    const targetDate = targetTime.toISOString().split('T')[0]
    const targetHour = targetTime.getHours().toString().padStart(2, '0')
    const targetMinute = targetTime.getMinutes().toString().padStart(2, '0')
    const targetTimeStr = `${targetHour}:${targetMinute}`

    console.log(`Buscando eventos para: ${targetDate} a las ${targetTimeStr} (${minutes_before} min antes)`)

    // 1. Obtener eventos que coincidan con la fecha y hora objetivo
    // Buscamos eventos cuya hora esté en un rango de ±5 minutos
    const { data: eventos, error: eventosError } = await supabase
      .from('evento')
      .select('id_evento, nombre, fecha, hora, ubicacion')
      .eq('fecha', targetDate)

    if (eventosError) {
      console.error('Error obteniendo eventos:', eventosError)
      throw eventosError
    }

    // Filtrar eventos por hora (±5 minutos de tolerancia)
    const eventosEnRango = (eventos || []).filter(evento => {
      if (!evento.hora) return false
      const [eventHour, eventMinute] = evento.hora.split(':').map(Number)
      const [targetH, targetM] = [targetTime.getHours(), targetTime.getMinutes()]

      // Calcular diferencia en minutos
      const eventMinutes = eventHour * 60 + eventMinute
      const targetMinutes = targetH * 60 + targetM
      const diff = Math.abs(eventMinutes - targetMinutes)

      return diff <= 5 // ±5 minutos de tolerancia
    })

    if (eventosEnRango.length === 0) {
      return new Response(
        JSON.stringify({
          message: `No hay eventos en ${minutes_before} minutos`,
          checked_date: targetDate,
          checked_time: targetTimeStr
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`Encontrados ${eventosEnRango.length} eventos próximos`)

    const notificationsSent: any[] = []

    // 2. Para cada evento, obtener estudiantes registrados con FCM token
    for (const evento of eventosEnRango) {
      const { data: registros, error: registrosError } = await supabase
        .from('estudiante_evento')
        .select(`
          id_estudiante,
          estudiante!inner(
            usuario!inner(
              nombre,
              fcm_token
            )
          )
        `)
        .eq('id_evento', evento.id_evento)

      if (registrosError) {
        console.error(`Error obteniendo registros para evento ${evento.id_evento}:`, registrosError)
        continue
      }

      // Mensaje según el tiempo
      let timeMessage = ''
      if (minutes_before <= 10) {
        timeMessage = '¡en 10 minutos!'
      } else if (minutes_before <= 15) {
        timeMessage = 'en 15 minutos'
      } else if (minutes_before <= 30) {
        timeMessage = 'en 30 minutos'
      } else if (minutes_before <= 60) {
        timeMessage = 'en 1 hora'
      } else {
        timeMessage = 'pronto'
      }

      // 3. Enviar notificación a cada estudiante
      for (const registro of registros || []) {
        const fcmToken = registro.estudiante?.usuario?.fcm_token

        if (!fcmToken) continue

        try {
          const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
            method: 'POST',
            headers: {
              'Authorization': `key=${Deno.env.get('FCM_SERVER_KEY')}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              to: fcmToken,
              notification: {
                title: '⏰ ¡Recordatorio!',
                body: `"${evento.nombre}" comienza ${timeMessage}${evento.ubicacion ? ` en ${evento.ubicacion}` : ''}`,
              },
              data: {
                type: 'event_reminder',
                evento_id: evento.id_evento,
                minutes_before: minutes_before.toString(),
              },
            }),
          })

          const result = await fcmResponse.json()
          notificationsSent.push({
            evento: evento.nombre,
            estudiante: registro.estudiante?.usuario?.nombre,
            result,
          })
        } catch (fcmError) {
          console.error('Error enviando FCM:', fcmError)
        }
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        minutes_before,
        eventos_encontrados: eventosEnRango.length,
        notificaciones_enviadas: notificationsSent.length,
        detalles: notificationsSent
      }),
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
