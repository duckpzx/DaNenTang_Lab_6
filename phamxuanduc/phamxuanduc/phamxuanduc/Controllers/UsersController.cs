using phamxuanduc.Data;
using phamxuanduc.DTOs;
using phamxuanduc.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace phamxuanduc.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // All endpoints require authentication
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UsersController(AppDbContext context)
        {
            _context = context;
        }

        // GET api/users — Admin only: get all users
        [HttpGet]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAllUsers()
        {
            var users = await _context.Users
                .Select(u => new UserDto
                {
                    Id = u.Id,
                    Username = u.Username,
                    Role = u.Role,
                    CreatedAt = u.CreatedAt
                })
                .ToListAsync();

            return Ok(users);
        }

        // GET api/users/{id} — Admin can get any user; User can only get themselves
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUser(int id)
        {
            var currentUserId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var currentRole = User.FindFirstValue(ClaimTypes.Role);

            // Regular users can only view their own profile
            if (currentRole != "Admin" && currentUserId != id)
                return Forbid();

            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound(new { message = "User not found." });

            return Ok(new UserDto
            {
                Id = user.Id,
                Username = user.Username,
                Role = user.Role,
                CreatedAt = user.CreatedAt
            });
        }

        // GET api/users/me — Any authenticated user: get own profile
        [HttpGet("me")]
        public async Task<IActionResult> GetMe()
        {
            var currentUserId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)!);

            var user = await _context.Users.FindAsync(currentUserId);
            if (user == null)
                return NotFound(new { message = "User not found." });

            return Ok(new UserDto
            {
                Id = user.Id,
                Username = user.Username,
                Role = user.Role,
                CreatedAt = user.CreatedAt
            });
        }

        // POST api/users — Admin only: create user with any role
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CreateUser([FromBody] RegisterDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (await _context.Users.AnyAsync(u => u.Username == dto.Username))
                return Conflict(new { message = "Username already exists." });

            var allowedRoles = new[] { "Admin", "User" };
            if (!allowedRoles.Contains(dto.Role))
                return BadRequest(new { message = "Role must be 'Admin' or 'User'." });

            var user = new User
            {
                Username = dto.Username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                Role = dto.Role,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetUser), new { id = user.Id }, new UserDto
            {
                Id = user.Id,
                Username = user.Username,
                Role = user.Role,
                CreatedAt = user.CreatedAt
            });
        }

        // PUT api/users/{id} — Admin can update any user; User can only update themselves (no role change)
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var currentUserId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var currentRole = User.FindFirstValue(ClaimTypes.Role);

            // Regular users can only update themselves
            if (currentRole != "Admin" && currentUserId != id)
                return Forbid();

            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound(new { message = "User not found." });

            // Only Admin can change roles
            if (dto.Role != null && currentRole != "Admin")
                return Forbid();

            if (!string.IsNullOrWhiteSpace(dto.Username))
            {
                if (await _context.Users.AnyAsync(u => u.Username == dto.Username && u.Id != id))
                    return Conflict(new { message = "Username already exists." });
                user.Username = dto.Username;
            }

            if (!string.IsNullOrWhiteSpace(dto.Password))
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);

            if (!string.IsNullOrWhiteSpace(dto.Role) && currentRole == "Admin")
            {
                var allowedRoles = new[] { "Admin", "User" };
                if (!allowedRoles.Contains(dto.Role))
                    return BadRequest(new { message = "Role must be 'Admin' or 'User'." });
                user.Role = dto.Role;
            }

            await _context.SaveChangesAsync();

            return Ok(new UserDto
            {
                Id = user.Id,
                Username = user.Username,
                Role = user.Role,
                CreatedAt = user.CreatedAt
            });
        }

        // DELETE api/users/{id} — Admin only
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var currentUserId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)!);

            // Prevent admin from deleting themselves
            if (currentUserId == id)
                return BadRequest(new { message = "Cannot delete your own account." });

            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound(new { message = "User not found." });

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return Ok(new { message = $"User '{user.Username}' deleted successfully." });
        }
    }
}
