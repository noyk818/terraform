using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using ModelContextProtocol;
using ModelContextProtocol.Server;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using System.Diagnostics;
using System.Text;

namespace SimpleMcpServer
{
    public static class Program
    {
        public static async Task Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            builder.Services
                .AddMcpServer()
                .WithHttpTransport()
                .WithToolsFromAssembly(typeof(MyTools).Assembly);

            var app = builder.Build();
            app.MapMcp("/mcp");

            await app.RunAsync();
        }
    }

    // ツールクラス
    [McpServerToolType] // クラスに必須
    public static class MyTools
    {
        [McpServerTool(Name = "echo", Title = "文字列をそのまま返します。")]
        public static string Echo(string message)
        {
            return $"You said: {message}";
        }

        [McpServerTool(Name = "add", Title = "2つの整数を加算します。")]
        public static int Add(int a, int b)
        {
            return a + b;
        }

        [McpServerTool(Name = "date", Title = "現在の時刻を取得します。")]
        public static string GetCurrentTime()
        {
            return DateTimeOffset.Now.ToString();
        }

        [McpServerTool(Name = "zone", Title = "指定されたタイムゾーンの現在の時刻を取得します。")]
        public static string GetTimeInTimeZone(string timeZone)
        {
            try
            {
                var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZone);
                return TimeZoneInfo.ConvertTime(DateTimeOffset.Now, tz).ToString();
            }
            catch
            {
                return "指定されたタイムゾーンが見つかりません。";
            }
        }
    }
}
